import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

/// In-process, loopback-only stand-in for HaloAI. No real login credentials,
/// server keys or business traffic are used. Data lives until logout/restart.
class HaloChatDemoServer {
  static const _api = '/api/client/inApp/v1/';
  static const _maxFile = 25 * 1024 * 1024;
  final _random = Random.secure();
  late final String _sessionId = _id();
  final _messages = <Map<String, dynamic>>[];
  final _sent = <String, Map<String, dynamic>>{};
  final _failedOnce = <String>{};
  final _uploads = <String, _DemoUpload>{};
  final _messageUploads = <String, String>{};
  final _sockets = <WebSocket>{};
  final _authenticated = <WebSocket>{};
  final _timers = <Timer>{};
  HttpServer? _server;
  String? _token;
  bool _closed = false;
  int _counter = 0;
  int _lastTimestamp = 0;
  int _storedBytes = 0;

  int get port => _server!.port;
  String get baseUrl => 'http://localhost:$port';
  String get realtimeUrl => 'ws://localhost:$port/ws/client';
  String _id() =>
      base64UrlEncode(List.generate(18, (_) => _random.nextInt(256)));

  Future<void> start() async {
    if (!kDebugMode) throw StateError('Demo server is debug-only');
    if (_server != null) return;
    if (_closed) throw StateError('Demo session closed');
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    if (_closed) {
      await server.close(force: true);
      throw StateError('Demo session closed');
    }
    _server = server;
    _addMessage(
      'MODE DEMO — pesan dan lampiran hanya disimpan sementara di perangkat ini. Tidak terhubung ke CS sungguhan.',
      agent: true,
    );
    _addMessage(
      'Halo, saya ingin menanyakan pesanan contoh TM-DEMO-001.',
      agent: false,
    );
    _addMessage(
      'Pesanan contoh sedang disiapkan. Ketik “pesanan”, “produk”, atau “pembayaran” untuk mencoba balasan otomatis. Ketik /retry untuk mencoba kirim ulang dan /refresh untuk pembaruan token.',
      agent: true,
    );
    server.listen((request) => unawaited(_handle(request)));
  }

  String mintToken({bool forceRefresh = false}) {
    if (_server == null || _closed) {
      throw StateError('Demo server is not running');
    }
    if (forceRefresh || _token == null) _token = 'hct_demo_${_id()}';
    return _token!;
  }

  Map<String, dynamic> _addMessage(
    String? text, {
    required bool agent,
    _DemoUpload? upload,
  }) {
    _lastTimestamp = max(
      _lastTimestamp + 1,
      DateTime.now().millisecondsSinceEpoch,
    );
    final message = <String, dynamic>{
      'id': 'demo-$_sessionId-${++_counter}',
      'text': text,
      'sender': agent ? 'agent' : 'me',
      'senderKind': agent ? 'human' : 'customer',
      'hasMedia': upload != null,
      'mediaType': upload?.mimeType,
      'mediaFilename': upload?.filename,
      'createdAt': DateTime.fromMillisecondsSinceEpoch(
        _lastTimestamp,
        isUtc: true,
      ).toIso8601String(),
      'status': agent ? 'delivered' : 'read',
    };
    _messages.add(message);
    _broadcast({'type': 'message', 'message': message});
    return message;
  }

  void _broadcast(Map<String, dynamic> event) {
    for (final socket in _authenticated.toList()) {
      if (socket.readyState == WebSocket.open) socket.add(jsonEncode(event));
    }
  }

  void _later(void Function() action) {
    late Timer timer;
    timer = Timer(const Duration(milliseconds: 800), () {
      _timers.remove(timer);
      if (!_closed) action();
    });
    _timers.add(timer);
  }

  Future<void> _reply(
    HttpRequest request,
    Object body, {
    int status = 200,
  }) async {
    request.response.statusCode = status;
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode(body));
    await request.response.close();
  }

  Future<Map<String, dynamic>> _body(HttpRequest request) async {
    final bytes = await _bytes(request, 32768);
    return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
  }

  Future<Uint8List> _bytes(HttpRequest request, int limit) async {
    final buffer = BytesBuilder(copy: false);
    await for (final chunk in request.timeout(const Duration(seconds: 30))) {
      if (buffer.length + chunk.length > limit) {
        throw const FormatException('too large');
      }
      buffer.add(chunk);
    }
    return buffer.takeBytes();
  }

  Future<void> _handle(HttpRequest request) async {
    try {
      final path = request.uri.path;
      if (path == '/ws/client' &&
          WebSocketTransformer.isUpgradeRequest(request)) {
        final socket = await WebSocketTransformer.upgrade(request);
        _sockets.add(socket);
        socket.add(jsonEncode({'type': 'connected'}));
        final authTimeout = Timer(const Duration(seconds: 10), () {
          if (!_authenticated.contains(socket)) {
            unawaited(socket.close(4001, 'auth_required'));
          }
        });
        socket.listen(
          (raw) {
            try {
              final frame = jsonDecode(raw as String);
              if (frame['type'] == 'auth' &&
                  _token != null &&
                  frame['token'] == _token) {
                _authenticated.add(socket);
                authTimeout.cancel();
                socket.add(
                  jsonEncode({'type': 'authenticated', 'roomId': 'demo-room'}),
                );
              } else {
                unawaited(socket.close(4001, 'invalid_token'));
              }
            } catch (_) {
              unawaited(socket.close(4001, 'invalid_token'));
            }
          },
          onDone: () {
            authTimeout.cancel();
            _sockets.remove(socket);
            _authenticated.remove(socket);
          },
          onError: (Object _) {
            authTimeout.cancel();
            _sockets.remove(socket);
            _authenticated.remove(socket);
          },
        );
        return;
      }
      // Random, one-session URLs stand in for signed storage URLs.
      if (path.startsWith('/files/')) {
        final upload = _uploads[path.substring('/files/'.length)];
        if (upload == null) {
          await _reply(request, {'error': 'not_found'}, status: 404);
        } else if (request.method == 'PUT' && upload.bytes == null) {
          final bytes = await _bytes(request, _maxFile);
          if (bytes.length != upload.size ||
              _storedBytes + bytes.length > 50 * 1024 * 1024) {
            await _reply(request, {'error': 'upload_too_large'}, status: 400);
          } else {
            upload.bytes = bytes;
            _storedBytes += bytes.length;
            await _reply(request, {'data': {}});
          }
        } else if (request.method == 'GET' && upload.bytes != null) {
          request.response.headers.contentType = ContentType.parse(
            upload.mimeType,
          );
          request.response.add(upload.bytes!);
          await request.response.close();
        } else {
          await _reply(request, {'error': 'upload_missing'}, status: 400);
        }
        return;
      }
      if (_token == null ||
          request.headers.value('Authorization') != 'Bearer $_token') {
        await _reply(request, {'error': 'invalid_token'}, status: 401);
        return;
      }
      if (path == '${_api}conversation' && request.method == 'GET') {
        await _reply(request, {
          'data': {'roomId': 'demo-room', 'title': 'CS Top Mortar — Demo'},
        });
      } else if (path == '${_api}messages' && request.method == 'GET') {
        final query = request.uri.queryParameters;
        final limit = (int.tryParse(query['limit'] ?? '') ?? 50).clamp(1, 100);
        final before = int.tryParse(query['before'] ?? '') ?? _messages.length;
        final after = int.tryParse(query['after'] ?? '');
        final end = before.clamp(0, _messages.length);
        final start = after == null ? max(0, end - limit) : after.clamp(0, end);
        final page = _messages.sublist(start, min(end, start + limit));
        await _reply(request, {
          'data': {
            'messages': page,
            'newestCursor': '${start + page.length}',
            'oldestCursor': '$start',
          },
        });
      } else if (path == '${_api}messages' && request.method == 'POST') {
        final body = await _body(request);
        final key = request.headers.value('Idempotency-Key');
        if (key == null || key.length < 8) {
          await _reply(request, {'error': 'invalid_key'}, status: 400);
          return;
        }
        if (_sent.containsKey(key)) {
          await _reply(request, {
            'data': {'message': _sent[key]},
          });
          return;
        }
        final text = (body['text'] as String?)?.trim();
        final upload = _uploads[body['uploadId']];
        if (body['uploadId'] != null && upload?.bytes == null) {
          await _reply(request, {'error': 'upload_missing'}, status: 400);
          return;
        }
        if ((text == null || text.isEmpty) && upload?.bytes == null ||
            (text?.length ?? 0) > 4096) {
          await _reply(request, {'error': 'invalid_message'}, status: 400);
          return;
        }
        if (text == '/retry' && _failedOnce.add(key)) {
          await _reply(request, {'error': 'demo_retry'}, status: 503);
          return;
        }
        final message = _addMessage(text, agent: false, upload: upload);
        if (upload != null) {
          _messageUploads[message['id'] as String] = body['uploadId'] as String;
        }
        _sent[key] = message;
        await _reply(request, {
          'data': {'message': message},
        });
        _later(() {
          _addMessage(_answer(text, upload != null), agent: true);
          if (text == '/refresh') {
            _token = null;
            for (final socket in _sockets.toList()) {
              unawaited(socket.close(4001, 'token_expired'));
            }
            _authenticated.clear();
          }
        });
      } else if (path == '${_api}uploads' && request.method == 'POST') {
        final body = await _body(request);
        final size = body['sizeBytes'] as int;
        if (size < 1 || size > _maxFile || _uploads.length >= 50) {
          await _reply(request, {'error': 'upload_too_large'}, status: 400);
          return;
        }
        final id = _id();
        _uploads[id] = _DemoUpload(
          body['filename'] as String,
          body['mimeType'] as String,
          size,
        );
        await _reply(request, {
          'data': {
            'uploadId': id,
            'uploadUrl': '$baseUrl/files/$id',
            'uploadHeaders': {'Content-Type': body['mimeType']},
            'maxBytes': _maxFile,
          },
        });
      } else if (path.startsWith('${_api}media/') && request.method == 'GET') {
        final id = _messageUploads[path.substring('${_api}media/'.length)];
        await _reply(
          request,
          id == null
              ? {'error': 'not_found'}
              : {
                  'data': {'url': '$baseUrl/files/$id'},
                },
          status: id == null ? 404 : 200,
        );
      } else if (path == '${_api}session' && request.method == 'DELETE') {
        _token = null;
        for (final socket in _sockets.toList()) {
          unawaited(socket.close(4001, 'token_revoked'));
        }
        _authenticated.clear();
        await _reply(request, {'data': {}});
      } else {
        await _reply(request, {'error': 'not_found'}, status: 404);
      }
    } catch (_) {
      try {
        await _reply(request, {'error': 'invalid_request'}, status: 400);
      } catch (_) {
        // Client disconnected while a demo request was being processed.
      }
    }
  }

  String _answer(String? text, bool attachment) {
    if (attachment) {
      return '[Demo] Lampiran diterima dan dapat dibuka kembali. File hanya berada di perangkat ini.';
    }
    final query = (text ?? '').toLowerCase();
    if (query == '/refresh') {
      return '[Demo] Token akan kedaluwarsa sekarang. SDK akan meminta token dummy baru dan menyambung kembali.';
    }
    if (query == '/retry') {
      return '[Demo] Kirim ulang berhasil; idempotency key mencegah pesan ganda.';
    }
    if (query.contains('pesanan')) {
      return '[Demo] Pesanan TM-DEMO-001: 20 sak Top Mortar, status Sedang Disiapkan. Ini data contoh.';
    }
    if (query.contains('produk')) {
      return '[Demo] Produk contoh: mortar perekat bata ringan, kemasan 40 kg. Informasi dan ketersediaan ini bukan data penjualan aktual.';
    }
    if (query.contains('bayar')) {
      return '[Demo] Invoice INV-DEMO-001 berstatus Belum Dibayar. Tidak ada transaksi atau pembayaran sungguhan.';
    }
    return '[Demo] Terima kasih. Ini balasan otomatis lokal. Coba tanyakan pesanan, produk, atau pembayaran, atau kirim lampiran.';
  }

  Future<void> close() async {
    _closed = true;
    _token = null;
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
    for (final socket in _sockets.toList()) {
      unawaited(socket.close());
    }
    _sockets.clear();
    _authenticated.clear();
    await _server?.close(force: true);
    _server = null;
    _messages.clear();
    _uploads.clear();
    _messageUploads.clear();
    _sent.clear();
    _failedOnce.clear();
    _storedBytes = 0;
  }
}

class _DemoUpload {
  _DemoUpload(this.filename, this.mimeType, this.size);
  final String filename;
  final String mimeType;
  final int size;
  Uint8List? bytes;
}
