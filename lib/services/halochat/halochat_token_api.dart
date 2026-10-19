import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Backend adapter: change this one request/response mapping if the team's
/// final contract differs. User identity must be derived by the backend.
class HaloChatTokenApi {
  const HaloChatTokenApi(this.client, this.endpoint);
  final http.Client client;
  final Uri endpoint;

  Future<String> fetch({
    required String phone,
    required String password,
    required bool forceRefresh,
  }) async {
    try {
      final response = await client
          .post(
            endpoint,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'nomorhp': phone,
              'pass_contact': password,
              'forceRefresh': forceRefresh,
            }),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw PlatformException(
          code: 'signed_out',
          message: 'Silakan login kembali.',
        );
      }
      if (response.statusCode == 429) {
        throw PlatformException(
          code: 'rate_limited',
          message: 'Terlalu banyak percobaan. Silakan coba sebentar lagi.',
        );
      }
      if (response.statusCode != 200) throw const FormatException();
      final body = jsonDecode(response.body);
      final token = body is Map && body['data'] is Map
          ? body['data']['token']
          : null;
      if (token is! String ||
          !token.startsWith('hct_') ||
          token.startsWith('hct_demo_') ||
          token.length <= 4 ||
          token.contains(RegExp(r'\s'))) {
        throw const FormatException();
      }
      return token;
    } on PlatformException {
      rethrow;
    } catch (_) {
      // Never include credentials, backend response bodies or tokens in errors.
      throw PlatformException(
        code: 'token_failed',
        message: 'Chat belum dapat terhubung. Silakan coba lagi.',
      );
    }
  }
}
