import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:topmortarseller/services/halochat/halochat_config.dart';
import 'package:topmortarseller/services/halochat/halochat_demo_server.dart';
import 'package:topmortarseller/services/halochat/halochat_token_api.dart';
import 'package:topmortarseller/util/auth_settings.dart';

/// Native SDK owns token caching, refresh, realtime and attachments in both modes.
class HaloChatService {
  static const channel = MethodChannel(
    'com.topmortar.topmortarseller/halochat',
  );
  static bool _opening = false;
  static bool _nativeReady = false;
  static int _generation = 0;
  static HaloChatDemoServer? _demoServer;
  static Future<void>? _demoReady;

  static bool get isDemo => HaloChatConfig.isDemo;
  static bool get supported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static void initialize() {
    channel.setMethodCallHandler((call) async {
      if (call.method != 'fetchToken') throw MissingPluginException();
      final arguments = call.arguments;
      if (arguments is! Map || arguments['generation'] != _generation) {
        throw PlatformException(
          code: 'signed_out',
          message: 'Silakan login kembali.',
        );
      }
      return fetchToken(forceRefresh: arguments['forceRefresh'] == true);
    });
  }

  static Future<String> fetchToken({required bool forceRefresh}) async {
    final generation = _generation;
    if (!await getLoginState()) {
      throw PlatformException(
        code: 'signed_out',
        message: 'Silakan login kembali.',
      );
    }
    HaloChatConfig.validateMode();
    final String token;
    if (isDemo) {
      final server = _demoServer ??= HaloChatDemoServer();
      await (_demoReady ??= server.start());
      token = server.mintToken(forceRefresh: forceRefresh);
    } else {
      final endpoint = HaloChatConfig.liveTokenUri();
      // Retain certificate validation despite the app-wide HttpOverrides.
      final client = IOClient(HttpClient()..badCertificateCallback = null);
      try {
        token = await HaloChatTokenApi(client, endpoint).fetch(
          phone: await getLoginPhone(),
          password: await getLoginPassword(),
          forceRefresh: forceRefresh,
        );
      } finally {
        client.close();
      }
    }
    if (generation != _generation || !await getLoginState()) {
      throw PlatformException(
        code: 'signed_out',
        message: 'Silakan login kembali.',
      );
    }
    return token;
  }

  static Future<void> openChat() async {
    if (_opening) return;
    if (!supported) {
      throw PlatformException(
        code: 'unsupported',
        message: 'Chat tersedia di Android dan iOS.',
      );
    }
    _opening = true;
    final generation = _generation;
    try {
      HaloChatConfig.validateMode();
      if (!await getLoginState()) {
        throw PlatformException(
          code: 'signed_out',
          message: 'Silakan login kembali.',
        );
      }
      initialize();
      // Reopening the same session must not mint an unused backend token.
      final token = _nativeReady ? null : await fetchToken(forceRefresh: false);
      if (generation != _generation) return;
      await channel.invokeMethod<void>('openChat', {
        'token': token,
        'generation': generation,
        'resetSession': !_nativeReady,
        if (isDemo) 'demoPort': _demoServer!.port,
      });
      if (generation == _generation) _nativeReady = true;
    } finally {
      _opening = false;
    }
  }

  static Future<void> clearUser() async {
    _generation++;
    _nativeReady = false;
    final server = _demoServer;
    _demoServer = null;
    _demoReady = null;
    try {
      if (supported) {
        await channel
            .invokeMethod<void>('clearUser')
            .timeout(const Duration(seconds: 5));
      }
    } catch (_) {
      // An offline chat server must not prevent app logout.
    } finally {
      await server?.close();
    }
  }
}
