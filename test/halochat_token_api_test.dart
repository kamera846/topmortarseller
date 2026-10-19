import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:topmortarseller/services/halochat/halochat_config.dart';
import 'package:topmortarseller/services/halochat/halochat_token_api.dart';

void main() {
  final endpoint = Uri.https('backend.example', '/api/halochat/token');
  test(
    'backend contract sends credentials and forceRefresh, parses client token',
    () async {
      final api = HaloChatTokenApi(
        MockClient((request) async {
          expect(request.url, endpoint);
          expect(request.method, 'POST');
          expect(jsonDecode(request.body), {
            'nomorhp': '08000000000',
            'pass_contact': 'dummy-password',
            'forceRefresh': true,
          });
          return http.Response(
            '{"data":{"token":"hct_test_only","expiresAt":"2030-01-01T00:00:00Z"}}',
            200,
          );
        }),
        endpoint,
      );
      expect(
        await api.fetch(
          phone: '08000000000',
          password: 'dummy-password',
          forceRefresh: true,
        ),
        'hct_test_only',
      );
    },
  );

  for (final status in [401, 403, 429, 500]) {
    test('HTTP $status has a safe actionable error', () async {
      final api = HaloChatTokenApi(
        MockClient(
          (_) async => http.Response('secret-server-response', status),
        ),
        endpoint,
      );
      await expectLater(
        api.fetch(phone: 'dummy', password: 'dummy', forceRefresh: false),
        throwsA(
          isA<PlatformException>()
              .having(
                (e) => e.code,
                'code',
                status == 429
                    ? 'rate_limited'
                    : status == 500
                    ? 'token_failed'
                    : 'signed_out',
              )
              .having(
                (e) => e.message,
                'message',
                isNot(contains('secret-server-response')),
              ),
        ),
      );
    });
  }

  for (final body in [
    '<html>error</html>',
    '{"data":null}',
    '{"data":{"token":"hck_server_key"}}',
    '{"data":{"token":"hct_"}}',
    '{"data":{"token":"hct_demo_not_for_production"}}',
  ]) {
    test('invalid token response is rejected: $body', () async {
      final api = HaloChatTokenApi(
        MockClient((_) async => http.Response(body, 200)),
        endpoint,
      );
      await expectLater(
        api.fetch(phone: 'dummy', password: 'dummy', forceRefresh: false),
        throwsA(
          isA<PlatformException>().having(
            (e) => e.code,
            'code',
            'token_failed',
          ),
        ),
      );
    });
  }

  test(
    'live config requires HTTPS and rejects embedded secrets or query strings',
    () {
      expect(HaloChatConfig.liveTokenUri(url: endpoint.toString()), endpoint);
      for (final url in [
        '',
        'http://example.com/api/token',
        'https://user:pass@example.com/token',
        'https://example.com/token?key=secret',
      ]) {
        expect(
          () => HaloChatConfig.liveTokenUri(url: url, path: ''),
          throwsA(isA<PlatformException>()),
        );
      }
    },
  );
}
