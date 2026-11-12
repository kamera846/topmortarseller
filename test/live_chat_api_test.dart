import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/services/live_chat_api.dart';

const contact = ContactModel(
  idContact: '2726',
  nama: 'Trial Toko Bangunan Rafli',
  nomorhp: '62895636998639',
);

Map<String, dynamic> tokenResponse({
  String token = 'hct_test',
  DateTime? expiry,
}) => {
  'code': 200,
  'status': 'ok',
  'msg': 'Success get token',
  'data': {
    'token': token,
    'expiresAt': (expiry ?? DateTime.now().add(const Duration(hours: 1)))
        .toUtc()
        .toIso8601String(),
    'roomId': 'room-123',
  },
};

void main() {
  test('uses seller endpoint and parses the documented envelope', () async {
    final api = LiveChatApi(
      createClient: () => MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.scheme, 'https');
        expect(request.url.path, '/api/livechat/get-token');
        expect(request.url.queryParameters, isEmpty);
        expect(jsonDecode(request.body), {
          'id_contact': '2726',
          'nama': 'Trial Toko Bangunan Rafli',
          'nomorhp': '62895636998639',
        });
        expect(request.headers['Cache-Control'], 'no-store');
        return http.Response(jsonEncode(tokenResponse()), 200);
      }),
    );
    final session = await api.getToken(contact: contact);
    expect(session.token, 'hct_test');
    expect(session.roomId, 'room-123');
    expect(session.canReuse(DateTime.now()), isTrue);
    expect(
      session.canReuse(session.expiresAt.subtract(const Duration(seconds: 30))),
      isFalse,
    );
  });

  test('HTTP and envelope authentication errors require login', () async {
    for (final response in [
      http.Response('private backend diagnostic', 401),
      http.Response(jsonEncode({'code': 401}), 200),
    ]) {
      final api = LiveChatApi(
        createClient: () => MockClient((_) async => response),
      );
      await expectLater(
        api.getToken(contact: contact),
        throwsA(
          isA<LiveChatException>().having(
            (e) => e.requiresLogin,
            'requiresLogin',
            true,
          ),
        ),
      );
    }
  });

  test('gateway access denial does not incorrectly expire the login', () async {
    final api = LiveChatApi(
      createClient: () => MockClient(
        (_) async => http.Response(
          jsonEncode({'status': 403, 'cloudflare_error': true}),
          403,
        ),
      ),
    );
    await expectLater(
      api.getToken(contact: contact),
      throwsA(
        isA<LiveChatException>().having(
          (e) => e.requiresLogin,
          'requiresLogin',
          false,
        ),
      ),
    );
  });

  test('rejects malformed, expired and server-key responses', () async {
    final responses = [
      '<html>private error</html>',
      jsonEncode({'code': 200, 'status': 'ok', 'data': []}),
      jsonEncode(tokenResponse(token: 'hck_server_secret')),
      jsonEncode(
        tokenResponse(
          expiry: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
      ),
      jsonEncode({
        ...tokenResponse(),
        'data': {'token': 'hct_test'},
      }),
    ];
    for (final response in responses) {
      final api = LiveChatApi(
        createClient: () =>
            MockClient((_) async => http.Response(response, 200)),
      );
      await expectLater(
        api.getToken(contact: contact),
        throwsA(isA<LiveChatException>()),
      );
    }
  });

  test('rate limiting prevents immediate requests to backend', () async {
    var requests = 0;
    final api = LiveChatApi(
      createClient: () => MockClient((_) async {
        requests++;
        return http.Response('', 429, headers: {'retry-after': '60'});
      }),
    );
    for (var i = 0; i < 2; i++) {
      await expectLater(
        api.getToken(contact: contact),
        throwsA(isA<LiveChatException>()),
      );
    }
    expect(requests, 1);
  });

  test('network failures expose a safe actionable message', () async {
    for (final error in [
      http.ClientException('secret diagnostic'),
      TimeoutException('secret'),
    ]) {
      final api = LiveChatApi(
        createClient: () => MockClient((_) async => throw error),
      );
      await expectLater(
        api.getToken(contact: contact),
        throwsA(
          isA<LiveChatException>().having(
            (e) => e.message,
            'safe message',
            isNot(contains('secret')),
          ),
        ),
      );
    }
  });
}
