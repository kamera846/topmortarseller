import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:topmortarseller/services/halochat_service.dart';
import 'package:topmortarseller/services/halochat/halochat_config.dart';
import 'package:topmortarseller/util/auth_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(HaloChatService.clearUser);

  test('native callbacks from a previous login cannot mint a token', () async {
    await saveLoginState('08123456789', 'test-password');
    HaloChatService.initialize();
    const codec = StandardMethodCodec();
    final response = Completer<ByteData?>();
    TestWidgetsFlutterBinding.instance.channelBuffers.push(
      HaloChatService.channel.name,
      codec.encodeMethodCall(
        const MethodCall('fetchToken', {
          'forceRefresh': true,
          'generation': -1,
        }),
      ),
      response.complete,
    );
    final envelope = await response.future;
    expect(
      () => codec.decodeEnvelope(envelope!),
      throwsA(
        isA<PlatformException>().having((e) => e.code, 'code', 'signed_out'),
      ),
    );
  });

  test('signed-out users cannot request a chat token', () async {
    await expectLater(
      HaloChatService.fetchToken(forceRefresh: false),
      throwsA(
        isA<PlatformException>().having((e) => e.code, 'code', 'signed_out'),
      ),
    );
  });

  test(
    'missing backend configuration fails before sending credentials',
    () async {
      await saveLoginState('08123456789', 'test-password');
      expect(
        () => HaloChatConfig.liveTokenUri(url: '', path: ''),
        throwsA(
          isA<PlatformException>().having(
            (e) => e.code,
            'code',
            'not_configured',
          ),
        ),
      );
    },
  );

  test(
    'debug defaults to a local demo token that rotates on refresh',
    () async {
      await saveLoginState('08123456789', 'test-password');
      final token = await HaloChatService.fetchToken(forceRefresh: false);
      expect(token, startsWith('hct_demo_'));
      expect(await HaloChatService.fetchToken(forceRefresh: false), token);
      expect(
        await HaloChatService.fetchToken(forceRefresh: true),
        isNot(token),
      );
    },
  );

  test('logout still clears app credentials without a native plugin', () async {
    await saveLoginState('08123456789', 'test-password');
    await removeLoginState();
    expect(await getLoginState(), false);
    expect(await getLoginPhone(), isEmpty);
    expect(await getLoginPassword(), isEmpty);
  });
}
