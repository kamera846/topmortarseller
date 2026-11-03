import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:topmortarseller/screen/live_chat/live_chat_screen.dart';
import 'package:topmortarseller/services/live_chat_api.dart';

Future<void> openChatScreen(
  WidgetTester tester, {
  required Future<void> Function({bool Function()? isActive}) openChat,
  Future<void> Function()? signInAgain,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => LiveChatScreen(
                  openChat: openChat,
                  signInAgain: signInAgain,
                ),
              ),
            ),
            child: const Text('Buka bantuan'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Buka bantuan'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
}

void main() {
  testWidgets(
    'automatically connects and retries once without exposing errors',
    (tester) async {
      var requests = 0;
      final opened = Completer<void>();
      await openChatScreen(
        tester,
        openChat: ({isActive}) async {
          requests++;
          if (requests == 1) throw StateError('hct_private_token');
          await opened.future;
        },
      );
      await tester.pumpAndSettle();
      expect(requests, 1);
      expect(find.text('Chat belum dapat dibuka'), findsOneWidget);
      expect(find.textContaining('hct_private_token'), findsNothing);

      await tester.tap(find.text('Coba lagi'));
      await tester.tap(find.text('Coba lagi'));
      await tester.pump();
      expect(requests, 2);
      expect(find.text('Coba lagi'), findsNothing);
      expect(find.text('Batal'), findsOneWidget);

      opened.complete();
      await tester.pumpAndSettle();
      expect(find.byType(LiveChatScreen), findsNothing);
      expect(find.text('Buka bantuan'), findsOneWidget);
    },
  );

  testWidgets('cancel prevents a late connection from presenting chat', (
    tester,
  ) async {
    final connection = Completer<void>();
    var nativePresentations = 0;
    await openChatScreen(
      tester,
      openChat: ({isActive}) async {
        await connection.future;
        if (isActive?.call() ?? true) nativePresentations++;
      },
    );
    expect(find.text('Menghubungkan ke tim CS'), findsOneWidget);
    await tester.tap(find.text('Batal'));
    connection.complete();
    await tester.pumpAndSettle();
    expect(nativePresentations, 0);
    expect(find.text('Buka bantuan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('system back cancels a connection even during route transition', (
    tester,
  ) async {
    final connection = Completer<void>();
    var nativePresentations = 0;
    await openChatScreen(
      tester,
      openChat: ({isActive}) async {
        await connection.future;
        if (isActive?.call() ?? true) nativePresentations++;
      },
    );
    await tester.binding.handlePopRoute();
    connection.complete();
    await tester.pumpAndSettle();
    expect(nativePresentations, 0);
    expect(find.text('Buka bantuan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('expired login offers sign-in and lets the customer return', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await openChatScreen(
      tester,
      openChat: ({isActive}) async {
        throw const LiveChatException(
          'Sesi Anda berakhir. Silakan masuk kembali untuk menggunakan chat.',
          requiresLogin: true,
        );
      },
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Silakan masuk kembali'), findsOneWidget);
    expect(find.text('Coba lagi'), findsNothing);
    expect(find.text('Masuk kembali'), findsOneWidget);
    await tester.ensureVisible(find.text('Kembali'));
    await tester.tap(find.text('Kembali'));
    await tester.pumpAndSettle();
    expect(find.text('Buka bantuan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sign-in runs once and keeps navigation safe during cleanup', (
    tester,
  ) async {
    final signingIn = Completer<void>();
    var signInRequests = 0;
    await openChatScreen(
      tester,
      openChat: ({isActive}) async {
        throw const LiveChatException(
          'Silakan masuk kembali untuk menggunakan chat.',
          requiresLogin: true,
        );
      },
      signInAgain: () async {
        signInRequests++;
        await signingIn.future;
      },
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Masuk kembali'));
    await tester.tap(find.text('Masuk kembali'));
    await tester.pump();
    expect(signInRequests, 1);
    expect(find.text('Menyiapkan…'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(LiveChatScreen), findsOneWidget);
    signingIn.complete();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
