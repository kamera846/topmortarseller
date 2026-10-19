import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:topmortarseller/services/halochat/halochat_demo_server.dart';

void main() {
  late HaloChatDemoServer server;
  late http.Client client;
  late String token;
  Uri api(String path) =>
      Uri.parse('${server.baseUrl}/api/client/inApp/v1/$path');
  Map<String, String> headers([String? key]) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
    if (key != null) 'Idempotency-Key': key,
  };
  Future<http.Response> send(String text, String key) => client.post(
    api('messages'),
    headers: headers(key),
    body: jsonEncode({'text': text}),
  );

  setUp(() async {
    server = HaloChatDemoServer();
    await server.start();
    token = server.mintToken();
    client = http.Client();
  });
  tearDown(() async {
    client.close();
    await server.close();
  });

  test(
    'native API returns demo history and older/newer cursor pages',
    () async {
      final unauthenticated = await client.get(api('messages'));
      expect(unauthenticated.statusCode, 401);
      final response = await client.get(
        api('messages?limit=2'),
        headers: headers(),
      );
      final data = jsonDecode(response.body)['data'];
      expect(data['messages'], hasLength(2));
      final older = await client.get(
        api('messages?before=${data['oldestCursor']}'),
        headers: headers(),
      );
      expect(jsonDecode(older.body)['data']['messages'], hasLength(1));
      final newer = await client.get(
        api('messages?after=${data['newestCursor']}'),
        headers: headers(),
      );
      expect(jsonDecode(newer.body)['data']['messages'], isEmpty);
    },
  );

  test('real websocket delivers reply, retry reuses message id', () async {
    final socket = await WebSocket.connect(server.realtimeUrl);
    final reply = Completer<Map<String, dynamic>>();
    socket.listen((raw) {
      final frame = jsonDecode(raw as String);
      if (frame['type'] == 'message' &&
          frame['message']['sender'] == 'agent' &&
          !reply.isCompleted) {
        reply.complete(frame['message'] as Map<String, dynamic>);
      }
    });
    socket.add(jsonEncode({'type': 'auth', 'token': token}));
    expect((await send('/retry', 'retry-key-123')).statusCode, 503);
    final sent = await send('/retry', 'retry-key-123');
    final duplicate = await send('/retry', 'retry-key-123');
    expect(
      jsonDecode(sent.body)['data']['message']['id'],
      jsonDecode(duplicate.body)['data']['message']['id'],
    );
    expect(
      (await reply.future.timeout(const Duration(seconds: 5)))['text'],
      contains('Kirim ulang berhasil'),
    );
    await socket.close();
  });

  test('upload, message and media download preserve bytes', () async {
    final bytes = utf8.encode('Dummy invoice — no real payment');
    final ticket = await client.post(
      api('uploads'),
      headers: headers(),
      body: jsonEncode({
        'filename': 'invoice-demo.txt',
        'mimeType': 'text/plain',
        'sizeBytes': bytes.length,
      }),
    );
    final upload = jsonDecode(ticket.body)['data'];
    expect(
      (await client.put(
        Uri.parse(upload['uploadUrl']),
        body: bytes,
      )).statusCode,
      200,
    );
    final sent = await client.post(
      api('messages'),
      headers: headers('upload-key-123'),
      body: jsonEncode({'uploadId': upload['uploadId']}),
    );
    final message = jsonDecode(sent.body)['data']['message'];
    expect(message['hasMedia'], true);
    final media = await client.get(
      api('media/${message['id']}'),
      headers: headers(),
    );
    final file = await client.get(
      Uri.parse(jsonDecode(media.body)['data']['url']),
    );
    expect(file.bodyBytes, bytes);
  });

  test(
    '/refresh expires the socket and REST token, preserving history',
    () async {
      final socket = await WebSocket.connect(server.realtimeUrl);
      final authenticated = Completer<void>();
      final closed = Completer<void>();
      socket.listen((raw) {
        if (jsonDecode(raw as String)['type'] == 'authenticated') {
          authenticated.complete();
        }
      }, onDone: closed.complete);
      socket.add(jsonEncode({'type': 'auth', 'token': token}));
      await authenticated.future.timeout(const Duration(seconds: 5));
      expect((await send('/refresh', 'refresh-key-123')).statusCode, 200);
      await closed.future.timeout(const Duration(seconds: 5));
      expect(socket.closeCode, 4001);
      expect(
        (await client.get(api('messages'), headers: headers())).statusCode,
        401,
      );
      token = server.mintToken(forceRefresh: true);
      final history = await client.get(api('messages'), headers: headers());
      expect(history.statusCode, 200);
      expect(history.body, contains('Token akan kedaluwarsa'));
    },
  );

  test(
    'session revoke rejects old token and a refreshed token reconnects',
    () async {
      expect(
        (await client.delete(api('session'), headers: headers())).statusCode,
        200,
      );
      expect(
        (await client.get(api('conversation'), headers: headers())).statusCode,
        401,
      );
      final oldToken = token;
      token = server.mintToken(forceRefresh: true);
      expect(token, isNot(oldToken));
      expect(
        (await client.get(api('conversation'), headers: headers())).statusCode,
        200,
      );
    },
  );

  test('a new demo server never retains another login history', () async {
    final oldHistory = await client.get(api('messages'), headers: headers());
    final oldId = jsonDecode(oldHistory.body)['data']['messages'][0]['id'];
    await send('private demo message', 'private-key-123');
    await server.close();
    server = HaloChatDemoServer();
    await server.start();
    token = server.mintToken();
    final response = await client.get(api('messages'), headers: headers());
    expect(response.body, isNot(contains('private demo message')));
    expect(jsonDecode(response.body)['data']['messages'][0]['id'], isNot(oldId));
  });
}
