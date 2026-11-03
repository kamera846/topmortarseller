import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/services/live_chat_api.dart';
import 'package:topmortarseller/services/live_chat_service.dart';

class FakeChatApi extends LiveChatApi {
  int requests = 0;
  Future<LiveChatSession> Function(String userId)? handler;

  @override
  Future<LiveChatSession> getToken({required ContactModel contact}) async {
    final userId = contact.idContact!;
    requests++;
    return handler != null ? handler!(userId) : sessionFor(userId);
  }
}

LiveChatSession sessionFor(String userId) => LiveChatSession(
  token: 'hct_$userId',
  expiresAt: DateTime.now().add(const Duration(hours: 1)),
  roomId: 'room-$userId',
);

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('test/live_chat');
  const codec = StandardMethodCodec();
  late LiveChatService service;
  late FakeChatApi api;
  late List<MethodCall> calls;
  late DateTime now;
  String? userId;

  Future<dynamic> nativeToken({
    bool forceRefresh = false,
    String id = '42',
  }) async {
    final response = Completer<dynamic>();
    binding.defaultBinaryMessenger.handlePlatformMessage(
      channel.name,
      codec.encodeMethodCall(
        MethodCall('getToken', {'userId': id, 'forceRefresh': forceRefresh}),
      ),
      (data) {
        try {
          response.complete(codec.decodeEnvelope(data!));
        } catch (error, stack) {
          response.completeError(error, stack);
        }
      },
    );
    return response.future;
  }

  setUp(() {
    userId = '42';
    calls = [];
    api = FakeChatApi();
    now = DateTime.now();
    service = LiveChatService(
      api: api,
      channel: channel,
      readContact: () async => userId == null
          ? null
          : ContactModel(
              idContact: userId,
              nama: 'Toko Uji',
              nomorhp: '6281234',
            ),
      platformSupported: () => true,
      now: () => now,
    );
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      calls.add(call);
      return null;
    });
    service.initialize();
  });

  tearDown(() {
    channel.setMethodCallHandler(null);
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test(
    'prefetches a token then opens native chat and reuses valid session',
    () async {
      await service.openChat();
      expect(calls.map((call) => call.method), ['setUser', 'openChat']);
      expect(calls.first.arguments, {'userId': '42'});
      expect(await nativeToken(), 'hct_42');
      await service.openChat();
      expect(api.requests, 1);
      await nativeToken(forceRefresh: true);
      expect(api.requests, 2);
    },
  );

  test('concurrent refresh callbacks share one backend request', () async {
    await service.openChat();
    await nativeToken();
    final pending = Completer<LiveChatSession>();
    api.handler = (_) => pending.future;
    final first = nativeToken(forceRefresh: true);
    final second = nativeToken(forceRefresh: true);
    await Future<void>.delayed(Duration.zero);
    expect(api.requests, 2);
    pending.complete(sessionFor('42'));
    expect(await first, 'hct_42');
    expect(await second, 'hct_42');
  });

  test(
    'reopen after expiry gives native the prefetched token without another mint',
    () async {
      api.handler = (id) async => LiveChatSession(
        token: 'hct_${api.requests}',
        roomId: 'room-$id',
        expiresAt: now.add(const Duration(hours: 1)),
      );
      await service.openChat();
      expect(await nativeToken(), 'hct_1');
      now = now.add(const Duration(hours: 2));
      await service.openChat();
      expect(api.requests, 2);
      expect(await nativeToken(forceRefresh: true), 'hct_2');
      expect(api.requests, 2);
    },
  );

  test(
    'logout during account switch cannot restore the pending account',
    () async {
      await service.openChat();
      userId = '99';
      final clearing = Completer<void>();
      binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        calls.add(call);
        if (call.method == 'clearUser') await clearing.future;
        return null;
      });
      final opening = service.openChat();
      final expectation = expectLater(
        opening,
        throwsA(isA<LiveChatException>()),
      );
      await Future<void>.delayed(Duration.zero);
      final logout = service.clearUser();
      userId = null;
      clearing.complete();
      await logout;
      await expectation;
      expect(api.requests, 1);
      expect(calls.where((call) => call.method == 'openChat'), hasLength(1));
    },
  );

  test(
    'a second open during connection reports busy instead of false success',
    () async {
      final pending = Completer<LiveChatSession>();
      api.handler = (_) => pending.future;
      final opening = service.openChat();
      await Future<void>.delayed(Duration.zero);
      await expectLater(service.openChat(), throwsA(isA<LiveChatException>()));
      pending.complete(sessionFor('42'));
      await opening;
      expect(calls.where((call) => call.method == 'openChat'), hasLength(1));
    },
  );

  test('logout immediately after opening invalidates login lookup', () async {
    final opening = service.openChat();
    final expectation = expectLater(opening, throwsA(isA<LiveChatException>()));
    await service.clearUser();
    await expectation;
    expect(api.requests, 0);
    expect(calls.map((call) => call.method), ['clearUser']);
  });

  test('cancelled connecting screen cannot open native chat', () async {
    final pending = Completer<LiveChatSession>();
    api.handler = (_) => pending.future;
    var active = true;
    final opening = service.openChat(isActive: () => active);
    await Future<void>.delayed(Duration.zero);
    active = false;
    pending.complete(sessionFor('42'));
    await opening;
    expect(calls, isEmpty);
  });

  test(
    'logout invalidates an in-flight token and rejects old callbacks',
    () async {
      final pending = Completer<LiveChatSession>();
      api.handler = (_) => pending.future;
      final opening = service.openChat();
      final expectation = expectLater(
        opening,
        throwsA(isA<LiveChatException>()),
      );
      await Future<void>.delayed(Duration.zero);
      await service.clearUser();
      pending.complete(sessionFor('42'));
      await expectation;
      expect(calls.map((call) => call.method), ['clearUser']);
      await expectLater(
        nativeToken(),
        throwsA(
          isA<PlatformException>().having(
            (e) => e.code,
            'code',
            'AUTH_REQUIRED',
          ),
        ),
      );
    },
  );

  test(
    'switching accounts clears native state before opening another room',
    () async {
      await service.openChat();
      userId = '99';
      calls.clear();
      await service.openChat();
      expect(calls.map((call) => call.method), [
        'clearUser',
        'setUser',
        'openChat',
      ]);
      expect(await nativeToken(id: '99'), 'hct_99');
      await expectLater(
        nativeToken(id: '42'),
        throwsA(isA<PlatformException>()),
      );
    },
  );

  test('missing login never requests a token or invokes native UI', () async {
    userId = null;
    await expectLater(
      service.openChat(),
      throwsA(
        isA<LiveChatException>().having(
          (e) => e.requiresLogin,
          'requiresLogin',
          true,
        ),
      ),
    );
    expect(api.requests, 0);
    expect(calls, isEmpty);
  });
}
