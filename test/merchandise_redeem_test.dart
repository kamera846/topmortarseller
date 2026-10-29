import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:topmortarseller/model/merchandise_model.dart';
import 'package:topmortarseller/screen/merchandise/merchandise_detail_screen.dart';
import 'package:topmortarseller/screen/merchandise/merchandise_screen.dart';
import 'package:topmortarseller/services/merchandise_points.dart';
import 'package:topmortarseller/services/point_api.dart';
import 'package:topmortarseller/util/enum.dart';

const merchandise = {
  'id_merchandise': '7',
  'name_merchandise': 'Tumbler Top Mortar',
  'desc_merchandise': 'Tumbler untuk kegiatan sehari-hari.',
  'price_merchandise': '40',
};

http.Response response(
  Object? data, {
  int code = 200,
  String msg = 'Success',
}) => http.Response(jsonEncode({'code': code, 'msg': msg, 'data': data}), 200);

class RedeemServer {
  int total = 100;
  int posts = 0;
  int listLoads = 0;
  bool failTotal = false;
  bool failList = false;
  bool failDetail = false;
  bool empty = false;
  bool reject = false;
  bool failTotalAfterRedeem = false;
  Completer<http.Response>? pending;

  Future<http.Response> handle(http.Request request) async {
    switch (request.url.path) {
      case '/api/point/total':
        expect(request.url.queryParameters['id_contact'], '2726');
        return failTotal
            ? http.Response('', 500)
            : response({'val_point': total});
      case '/api/merchandise':
        listLoads++;
        return failList
            ? http.Response('', 500)
            : response(empty ? [] : [merchandise]);
      case '/api/merchandise/7':
        return failDetail ? http.Response('', 500) : response(merchandise);
      case '/api/point/redeem':
        posts++;
        expect(request.method, 'POST');
        expect(jsonDecode(request.body), {
          'id_contact': '2726',
          'id_merchandise': '7',
          'price_merchandise': '40',
        });
        if (pending != null) return pending!.future;
        if (reject) {
          return response(null, code: 400, msg: 'Poin tidak mencukupi.');
        }
        total -= 40;
        failTotal = failTotalAfterRedeem;
        // A successful response may have no data payload.
        return response(null);
      default:
        fail('Unexpected request: ${request.url}');
    }
  }
}

Future<void> openCatalog(
  WidgetTester tester, {
  ValueChanged<int?>? onChanged,
  double scale = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: MerchandiseScreen(idContact: '2726', onPointsChanged: onChanged),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> openDetail(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Tumbler Top Mortar'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Tumbler Top Mortar'));
  await tester.pumpAndSettle();
  expect(find.byType(MerchandiseDetailScreen), findsOneWidget);
}

Future<void> confirmRedeem(
  WidgetTester tester, {
  bool doubleConfirm = false,
}) async {
  await tester.tap(find.text('Tukar 40 Poin'));
  await tester.pumpAndSettle();
  expect(find.text('Sisa poin: 60 poin'), findsOneWidget);
  await tester.tap(find.text('Ya, Tukar Poin'));
  if (doubleConfirm) {
    // The dismissed dialog may already ignore pointer events on the second tap.
    await tester.tap(find.text('Ya, Tukar Poin'), warnIfMissed: false);
  }
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final notifications = <MethodCall>[];
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final cacheKey = '2726-${GlobalEnum.savedTotalPoint}';

  setUp(() {
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    SharedPreferences.setMockInitialValues({cacheKey: 100});
    notifications.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          notifications.add(call);
          return true;
        });
  });

  test(
    'merchandise accepts numeric identifiers and rejects invalid point costs',
    () {
      final item = MerchandiseModel.fromJson({
        ...merchandise,
        'id_merchandise': 7,
        'price_merchandise': 40,
      });
      expect(item.idMerchandise, '7');
      expect(item.pointCost, 40);
      for (final price in ['', 'abc', '-40', '0']) {
        expect(MerchandiseModel(priceMerchandise: price).pointCost, isNull);
      }
    },
  );

  test('redeem returns successful response even with null data', () async {
    final server = RedeemServer();
    await http.runWithClient(() async {
      final result = await PointApi.redeem(
        idContact: '2726',
        idMerchandise: '7',
        priceMerchandise: '40',
        onCompleted: (result) => expect(result?.code, 200),
      );
      expect(result?.code, 200);
      expect(server.posts, 1);
    }, () => MockClient(server.handle));
  });

  testWidgets(
    'redeem returns to catalog, synchronizes balance/cache and notifies once',
    (tester) async {
      final server = RedeemServer();
      final changes = <int?>[];
      await http.runWithClient(() async {
        await openCatalog(tester, onChanged: changes.add);
        await openDetail(tester);
        await confirmRedeem(tester);
        await tester.pumpAndSettle();
        expect(find.byType(MerchandiseDetailScreen), findsNothing);
        expect(find.text('60 poin'), findsOneWidget);
        expect(find.textContaining('berhasil ditukar'), findsOneWidget);
        expect(changes, contains(null));
        expect(changes.last, 60);
        expect((await SharedPreferences.getInstance()).getInt(cacheKey), 60);
        expect(server.posts, 1);
        expect(server.listLoads, 2);
        final shown = notifications
            .where((call) => call.method == 'show')
            .toList();
        expect(shown, hasLength(1));
        expect(shown.single.arguments['title'], 'Penukaran poin berhasil');
        await openDetail(tester);
        await tester.scrollUntilVisible(
          find.text('Sisa poin setelah penukaran: 20 poin.'),
          300,
          scrollable: find.byType(Scrollable).last,
        );
        expect(
          find.text('Sisa poin setelah penukaran: 20 poin.'),
          findsOneWidget,
        );
      }, () => MockClient(server.handle));
    },
  );

  testWidgets(
    'cancel does not redeem; in-flight request blocks duplicate taps and back',
    (tester) async {
      final server = RedeemServer()..pending = Completer<http.Response>();
      await http.runWithClient(() async {
        await openCatalog(tester);
        await openDetail(tester);
        await tester.tap(find.text('Tukar 40 Poin'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Batal'));
        await tester.pumpAndSettle();
        expect(server.posts, 0);
        await confirmRedeem(tester, doubleConfirm: true);
        await tester.pump(const Duration(milliseconds: 300));
        expect(server.posts, 1);
        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(button.onPressed, isNull);
        await tester.binding.handlePopRoute();
        await tester.pump();
        expect(find.byType(MerchandiseDetailScreen), findsOneWidget);
        server.total = 60;
        server.pending!.complete(response(null));
        await tester.pumpAndSettle();
        expect(server.posts, 1);
        expect(find.byType(MerchandiseDetailScreen), findsNothing);
      }, () => MockClient(server.handle));
    },
  );

  testWidgets('insufficient points disable redeem; exact balance can redeem', (
    tester,
  ) async {
    final server = RedeemServer()..total = 39;
    await http.runWithClient(() async {
      await openCatalog(tester);
      expect(find.text('Kurang 1 poin'), findsOneWidget);
      await openDetail(tester);
      expect(find.text('Poin Belum Cukup'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      server.total = 40;
      await tester.drag(find.byType(ListView).last, const Offset(0, 500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tukar 40 Poin'));
      await tester.pumpAndSettle();
      expect(find.text('Sisa poin: 0 poin'), findsOneWidget);
      await tester.tap(find.text('Ya, Tukar Poin'));
      await tester.pumpAndSettle();
      expect(find.text('0 poin'), findsOneWidget);
    }, () => MockClient(server.handle));
  });

  testWidgets(
    'API rejection retains detail and balance without a success notification',
    (tester) async {
      final server = RedeemServer()..reject = true;
      await http.runWithClient(() async {
        await openCatalog(tester);
        await openDetail(tester);
        await confirmRedeem(tester);
        await tester.pumpAndSettle();
        expect(find.byType(MerchandiseDetailScreen), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(SnackBar),
            matching: find.text('Poin tidak mencukupi.'),
          ),
          findsOneWidget,
        );
        expect((await SharedPreferences.getInstance()).getInt(cacheKey), 100);
        expect(notifications.where((call) => call.method == 'show'), isEmpty);
      }, () => MockClient(server.handle));
    },
  );

  testWidgets(
    'failed balance refresh after success never restores old points and can retry',
    (tester) async {
      final server = RedeemServer()..failTotalAfterRedeem = true;
      final changes = <int?>[];
      await http.runWithClient(() async {
        await openCatalog(tester, onChanged: changes.add);
        await openDetail(tester);
        await confirmRedeem(tester);
        await tester.pumpAndSettle();
        expect(find.byType(MerchandiseDetailScreen), findsNothing);
        expect(find.textContaining('berhasil ditukar'), findsOneWidget);
        expect(find.text('Saldo poin belum dapat dimuat.'), findsOneWidget);
        expect(find.text('100 poin'), findsNothing);
        expect(changes.last, isNull);
        expect(
          (await SharedPreferences.getInstance()).getInt(cacheKey),
          isNull,
        );
        server.failTotal = false;
        await tester.tap(find.text('Muat ulang poin'));
        await tester.pumpAndSettle();
        expect(find.text('60 poin'), findsOneWidget);
        expect(changes.last, 60);
        expect(server.posts, 1);
      }, () => MockClient(server.handle));
    },
  );

  testWidgets(
    'catalog and detail support error retry and empty catalog refresh',
    (tester) async {
      final server = RedeemServer()..failList = true;
      await http.runWithClient(() async {
        await openCatalog(tester);
        expect(find.text('Merchandise belum dapat dimuat.'), findsOneWidget);
        server.failList = false;
        server.empty = true;
        await tester.tap(find.text('Coba Lagi'));
        await tester.pumpAndSettle();
        expect(find.textContaining('Belum ada merchandise.'), findsOneWidget);
        server.empty = false;
        await tester.drag(find.byType(ListView), const Offset(0, 400));
        await tester.pumpAndSettle();
        server.failDetail = true;
        await openDetail(tester);
        expect(
          find.text('Detail merchandise belum dapat dimuat.'),
          findsOneWidget,
        );
        server.failDetail = false;
        await tester.tap(find.text('Coba Lagi'));
        await tester.pumpAndSettle();
        expect(find.text('Tukar 40 Poin'), findsOneWidget);
      }, () => MockClient(server.handle));
    },
  );

  testWidgets('narrow screens and large text keep confirmation usable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final server = RedeemServer();
    await http.runWithClient(() async {
      await openCatalog(tester, scale: 1.4);
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await openDetail(tester);
      await tester.tap(find.text('Tukar 40 Poin'));
      await tester.pumpAndSettle();
      expect(find.text('Ya, Tukar Poin'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }, () => MockClient(server.handle));
  });

  testWidgets('notification failure cannot undo a successful redemption', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'show') {
            throw PlatformException(code: 'permission_denied');
          }
          return true;
        });
    final server = RedeemServer();
    await http.runWithClient(() async {
      await openCatalog(tester);
      await openDetail(tester);
      await confirmRedeem(tester);
      await tester.pumpAndSettle();
      expect(find.text('60 poin'), findsOneWidget);
      expect(find.textContaining('berhasil ditukar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }, () => MockClient(server.handle));
  });

  testWidgets('leaving a loading catalog does not notify a disposed screen', (
    tester,
  ) async {
    final pending = Completer<http.Response>();
    await http.runWithClient(() async {
      await tester.pumpWidget(
        const MaterialApp(home: MerchandiseScreen(idContact: '2726')),
      );
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      pending.complete(response([]));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }, () => MockClient((_) => pending.future));
  });

  test('invalidating balance discards a stale in-flight response', () async {
    final stale = Completer<http.Response>();
    var requests = 0;
    final points = MerchandisePoints(idContact: '2726');
    await http.runWithClient(
      () async {
        final first = points.refresh();
        await points.invalidate();
        await points.refresh();
        expect(points.total, 60);
        stale.complete(response({'val_point': 100}));
        await first;
        expect(points.total, 60);
        expect((await SharedPreferences.getInstance()).getInt(cacheKey), 60);
        points.dispose();
      },
      () => MockClient((_) async {
        requests++;
        return requests == 1 ? stale.future : response({'val_point': 60});
      }),
    );
  });
}
