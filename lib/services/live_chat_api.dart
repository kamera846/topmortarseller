import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/services/api.dart';

/// Only a user-facing message crosses into the UI; never include tokens or bodies.
class LiveChatException implements Exception {
  const LiveChatException(this.message, {this.requiresLogin = false});

  final String message;
  final bool requiresLogin;
}

class LiveChatSession {
  const LiveChatSession({
    required this.token,
    required this.expiresAt,
    required this.roomId,
  });

  final String token;
  final DateTime expiresAt;
  final String roomId;

  factory LiveChatSession.fromJson(Map<String, dynamic> json) {
    final token = json['token'];
    final roomId = json['roomId'];
    final expiry = json['expiresAt'];
    final expiresAt = expiry is String ? DateTime.tryParse(expiry) : null;
    if (token is! String ||
        !token.startsWith('hct_') ||
        token.trim() != token ||
        token.length <= 4 ||
        roomId is! String ||
        roomId.trim().isEmpty ||
        expiresAt == null) {
      throw const LiveChatException(
        'Layanan chat belum siap. Silakan coba lagi sebentar.',
      );
    }
    return LiveChatSession(
      token: token,
      expiresAt: expiresAt.toUtc(),
      roomId: roomId,
    );
  }

  bool canReuse(DateTime now) =>
      expiresAt.isAfter(now.toUtc().add(const Duration(minutes: 1)));
}

/// The seller backend owns the HaloChat server key and chooses the user's room.
class LiveChatApi {
  LiveChatApi({http.Client Function()? createClient})
    : _createClient = createClient ?? _secureClient;

  static http.Client _secureClient() {
    // The app has a legacy HttpOverrides; chat credentials require valid TLS.
    return IOClient(HttpClient()..badCertificateCallback = null);
  }

  final http.Client Function() _createClient;
  DateTime? _retryAfter;

  Future<LiveChatSession> getToken({required ContactModel contact}) async {
    if (contact.idContact?.trim().isNotEmpty != true) {
      throw const LiveChatException(
        'Silakan masuk kembali untuk menggunakan chat.',
        requiresLogin: true,
      );
    }
    final retryAfter = _retryAfter;
    if (retryAfter != null && DateTime.now().isBefore(retryAfter)) {
      throw const LiveChatException(
        'Terlalu banyak permintaan. Tunggu sebentar lalu coba lagi.',
      );
    }

    final client = _createClient();
    try {
      final url = Uri.https(baseUrl, '/api/livechat/get-token');
      final response = await client
          .post(
            url,
            headers: {
              ...headerSetup,
              'Accept': 'application/json',
              'Cache-Control': 'no-store',
            },
            body: jsonEncode({
              'id_contact': contact.idContact,
              'nama': contact.nama ?? '',
              'nomorhp': contact.nomorhp ?? '',
            }),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 401) {
        throw const LiveChatException(
          'Sesi Anda berakhir. Silakan masuk kembali untuk menggunakan chat.',
          requiresLogin: true,
        );
      }
      if (response.statusCode == 403) {
        // Gateways can reject a request before it reaches the seller API.
        throw const LiveChatException(
          'Akses ke layanan chat ditolak. Silakan coba lagi nanti.',
        );
      }
      if (response.statusCode == 429) {
        _retryAfter = _retryAt(response.headers['retry-after']);
        throw const LiveChatException(
          'Terlalu banyak permintaan. Tunggu sebentar lalu coba lagi.',
        );
      }
      if (response.statusCode != 200) {
        throw const LiveChatException(
          'Layanan chat sedang tidak tersedia. Silakan coba lagi.',
        );
      }

      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) throw const FormatException();
      if (body['code'] == 401 || body['code'] == 403) {
        throw const LiveChatException(
          'Sesi Anda berakhir. Silakan masuk kembali untuk menggunakan chat.',
          requiresLogin: true,
        );
      }
      if (body['code'] != 200 ||
          body['status'] != 'ok' ||
          body['data'] is! Map<String, dynamic>) {
        throw const LiveChatException(
          'Chat belum dapat dibuka. Silakan coba lagi sebentar.',
        );
      }
      final session = LiveChatSession.fromJson(body['data']);
      if (!session.expiresAt.isAfter(DateTime.now().toUtc())) {
        throw const LiveChatException(
          'Sesi chat sudah kedaluwarsa. Silakan coba lagi.',
        );
      }
      return session;
    } on TimeoutException {
      throw const LiveChatException(
        'Koneksi terlalu lama. Periksa internet Anda lalu coba lagi.',
      );
    } on SocketException {
      throw const LiveChatException(
        'Tidak dapat terhubung. Periksa koneksi internet Anda.',
      );
    } on HandshakeException {
      throw const LiveChatException(
        'Koneksi aman ke layanan chat gagal. Silakan coba lagi nanti.',
      );
    } on http.ClientException {
      throw const LiveChatException(
        'Tidak dapat terhubung. Periksa koneksi internet Anda.',
      );
    } on FormatException {
      throw const LiveChatException(
        'Layanan chat belum siap. Silakan coba lagi sebentar.',
      );
    } finally {
      client.close();
    }
  }

  DateTime _retryAt(String? value) {
    final seconds = int.tryParse(value ?? '');
    if (seconds != null && seconds > 0) {
      return DateTime.now().add(Duration(seconds: seconds));
    }
    if (value != null) {
      try {
        final date = HttpDate.parse(value);
        if (date.isAfter(DateTime.now())) return date;
      } on FormatException {
        // Use a short backoff when the server omits a valid Retry-After value.
      }
    }
    return DateTime.now().add(const Duration(seconds: 30));
  }
}
