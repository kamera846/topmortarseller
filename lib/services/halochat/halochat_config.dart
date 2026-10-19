import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:topmortarseller/services/api.dart';

/// Only non-secret values belong in dart-define files.
abstract final class HaloChatConfig {
  static const mode = String.fromEnvironment(
    'HALOCHAT_MODE',
    defaultValue: kDebugMode ? 'demo' : 'live',
  );
  static const tokenPath = String.fromEnvironment('HALOCHAT_TOKEN_PATH');
  static const tokenUrl = String.fromEnvironment('HALOCHAT_TOKEN_URL');
  static bool get isDemo => kDebugMode && mode == 'demo';

  static void validateMode() {
    if (mode != 'live' && mode != 'demo' || mode == 'demo' && !kDebugMode) {
      throw PlatformException(
        code: 'invalid_config',
        message: 'Mode demo chat hanya tersedia pada build debug.',
      );
    }
  }

  static Uri liveTokenUri({String url = tokenUrl, String path = tokenPath}) {
    final uri = url.isNotEmpty
        ? Uri.tryParse(url)
        : path.startsWith('/api/')
        ? Uri.https(baseUrl, path)
        : null;
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasFragment ||
        uri.hasQuery ||
        uri.path == '/') {
      throw PlatformException(
        code: 'not_configured',
        message: 'Layanan chat belum tersedia.',
      );
    }
    return uri;
  }
}
