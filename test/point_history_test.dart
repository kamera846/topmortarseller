import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/model/point_model.dart';
import 'package:topmortarseller/screen/profile/detail_profile_screen.dart';
import 'package:topmortarseller/screen/profile/point_history_screen.dart';

Map<String, dynamic> transaction({
  String id = '63',
  Object? redeem,
  Object value = '3',
  String source = 'Full Payment',
  String date = '2026-09-12 13:03:06',
}) => {
  'id_point': id,
  'id_contact': '2726',
  'id_invoice': '17288',
  'source_point': source,
  'val_point': value,
  'id_point_redeem': redeem,
  'created_at': date,
};

http.Response success(List<Map<String, dynamic>> data) => http.Response(
  jsonEncode({'code': 200, 'status': 'ok', 'msg': 'Success', 'data': data}),
  200,
);

http.Response totalResponse(Object value) => http.Response(
  jsonEncode({
    'code': 200,
    'status': 'ok',
    'msg': 'Success',
    'data': {'val_point': value},
  }),
  200,
);

MockClient pointClient(Future<http.Response> Function(http.Request) handler) =>
    MockClient((request) async {
      if (request.url.path == '/api/point/total') {
        expect(request.url.queryParameters['id_contact'], '2726');
        return totalResponse('42');
      }
      return handler(request);
    });

Future<void> selectFilter(WidgetTester tester, String label) async {
  await tester.tap(find.textContaining('Filter:'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  testWidgets(
    'total failure leaves history usable and supports retry and refresh',
    (tester) async {
      var totalRequests = 0;
      var historyRequests = 0;
      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            const MaterialApp(home: PointHistoryScreen(idContact: '2726')),
          );
          await tester.pumpAndSettle();
          expect(find.text('Total poin belum dapat dimuat.'), findsOneWidget);
          expect(find.text('+3 poin'), findsOneWidget);
          expect(find.text('0 poin'), findsNothing);
          await tester.tap(find.text('Muat ulang total'));
          await tester.pumpAndSettle();
          expect(find.text('1.250 poin'), findsOneWidget);
          expect(historyRequests, 1);
          await tester.drag(find.byType(ListView), const Offset(0, 400));
          await tester.pumpAndSettle();
          expect(find.text('1.300 poin'), findsOneWidget);
          expect(historyRequests, 2);
        },
        () => MockClient((request) async {
          expect(request.url.queryParameters['id_contact'], '2726');
          if (request.url.path == '/api/point/total') {
            totalRequests++;
            if (totalRequests == 1) return http.Response('', 500);
            return totalResponse(totalRequests == 2 ? 1250 : '1300');
          }
          historyRequests++;
          return success([transaction()]);
        }),
      );
    },
  );

  testWidgets('floating filter leaves the last row clear on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await http.runWithClient(
      () async {
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            ),
            home: const PointHistoryScreen(idContact: '2726'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(find.text('Transaction 0'), 300);
        await tester.drag(find.byType(ListView), const Offset(0, -400));
        await tester.pumpAndSettle();
        final lastRow = find.widgetWithText(ListTile, 'Transaction 0');
        expect(lastRow, findsOneWidget);
        expect(
          tester.getBottomLeft(lastRow).dy,
          lessThan(tester.getTopLeft(find.text('Filter: Semua')).dy),
        );
        await selectFilter(tester, 'Poin Keluar');
        expect(find.text('Belum ada penukaran poin.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
      () => pointClient(
        (_) async => success([
          for (var i = 0; i < 8; i++)
            transaction(id: '$i', source: 'Transaction $i'),
        ]),
      ),
    );
  });

  test(
    'null redemption is incoming; every non-null redemption is outgoing',
    () {
      final incoming = PointModel.fromJson(transaction());
      expect(incoming.isRedeemed, isFalse);
      expect(incoming.formattedValue, '+3');
      for (final redeem in ['12', '', 0, 12]) {
        final outgoing = PointModel.fromJson(
          transaction(redeem: redeem, value: -3),
        );
        expect(outgoing.isRedeemed, isTrue);
        expect(outgoing.formattedValue, '−3');
      }
    },
  );

  testWidgets(
    'loads contact history, sorts newest first and filters directions',
    (tester) async {
      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            const MaterialApp(home: PointHistoryScreen(idContact: '2726')),
          );
          await tester.pumpAndSettle();
          expect(find.text('42 poin'), findsOneWidget);
          expect(find.text('+3 poin'), findsOneWidget);
          expect(find.text('−5 poin'), findsOneWidget);
          expect(find.text('12 September 2026, 13:03'), findsOneWidget);
          expect(find.text('Invoice #17288'), findsOneWidget);
          expect(find.text('Penukaran #9'), findsOneWidget);
          expect(
            tester.getTopLeft(find.text('Merchandise')).dy,
            lessThan(tester.getTopLeft(find.text('Full Payment')).dy),
          );

          await selectFilter(tester, 'Poin Keluar');
          expect(find.text('Merchandise'), findsOneWidget);
          expect(find.text('Full Payment'), findsNothing);

          await selectFilter(tester, 'Poin Masuk');
          expect(find.text('Full Payment'), findsOneWidget);
          expect(find.text('Merchandise'), findsNothing);

          await selectFilter(tester, 'Semua');
          expect(find.byType(ListTile), findsNWidgets(2));
        },
        () => pointClient((request) async {
          expect(request.url.path, '/api/point');
          expect(request.url.queryParameters['id_contact'], '2726');
          return success([
            transaction(),
            transaction(
              id: '64',
              redeem: '9',
              value: '5',
              source: 'Merchandise',
              date: '2026-09-13 13:03:06',
            ),
          ]);
        }),
      );
    },
  );

  testWidgets('empty history supports refresh and an outgoing empty state', (
    tester,
  ) async {
    var requests = 0;
    await http.runWithClient(
      () async {
        await tester.pumpWidget(
          const MaterialApp(home: PointHistoryScreen(idContact: '2726')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Belum ada riwayat poin.'), findsOneWidget);
        await selectFilter(tester, 'Poin Keluar');
        expect(find.text('Belum ada penukaran poin.'), findsOneWidget);
        await tester.drag(find.byType(ListView), const Offset(0, 400));
        await tester.pumpAndSettle();
        expect(requests, 2);
      },
      () => pointClient((_) async {
        requests++;
        return success([]);
      }),
    );
  });

  testWidgets('failed request can be retried', (tester) async {
    var requests = 0;
    await http.runWithClient(
      () async {
        await tester.pumpWidget(
          const MaterialApp(home: PointHistoryScreen(idContact: '2726')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Gagal memuat riwayat poin.'), findsOneWidget);
        await tester.tap(find.text('Coba Lagi'));
        await tester.pumpAndSettle();
        expect(find.text('+3 poin'), findsOneWidget);
        expect(find.text('Gagal memuat riwayat poin.'), findsNothing);
      },
      () => pointClient((_) async {
        requests++;
        return requests == 1
            ? http.Response('', 500)
            : success([transaction()]);
      }),
    );
  });

  testWidgets('leaving while loading does not update a disposed screen', (
    tester,
  ) async {
    final response = Completer<http.Response>();
    await http.runWithClient(() async {
      await tester.pumpWidget(
        const MaterialApp(home: PointHistoryScreen(idContact: '2726')),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      response.complete(success([transaction()]));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }, () => pointClient((_) => response.future));
  });

  testWidgets('profile without a bank shows vouchers and opens point history', (
    tester,
  ) async {
    await http.runWithClient(
      () async {
        await tester.pumpWidget(
          const MaterialApp(
            home: DetailProfileScreen(
              userData: ContactModel(idContact: '2726', nama: 'Toko Contoh'),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Anda belum menambahkan rekening!'), findsOneWidget);
        expect(find.text('Voucher Contoh'), findsOneWidget);
        await tester.tap(find.text('Riwayat Poin'));
        await tester.pumpAndSettle();
        expect(find.byType(PointHistoryScreen), findsOneWidget);
        expect(find.text('+3 poin'), findsOneWidget);
      },
      () => pointClient((request) async {
        if (request.url.path == '/api/point') {
          return success([transaction()]);
        }
        if (request.url.path.startsWith('/api/voucher/claimed/')) {
          return success([
            {'nama': 'Voucher Contoh', 'claim_date': '2026-09-12 13:03:06'},
          ]);
        }
        return success([]);
      }),
    );
  });

  testWidgets('profile handles a failed voucher request without null errors', (
    tester,
  ) async {
    await http.runWithClient(
      () async {
        await tester.pumpWidget(
          const MaterialApp(
            home: DetailProfileScreen(
              userData: ContactModel(idContact: '2726', nama: 'Toko Contoh'),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Riwayat Poin'), findsOneWidget);
      },
      () => pointClient((request) async {
        return request.url.path.startsWith('/api/voucher/claimed/')
            ? http.Response('', 500)
            : success([]);
      }),
    );
  });
}
