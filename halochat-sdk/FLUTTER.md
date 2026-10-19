# Using HaloChat from Flutter

There is no Flutter package yet. Pick one of two routes.

## Your backend first (both routes)

Your backend (never the app) calls `POST /api/open/inApp/v1/clientToken` with the
channel's server key (`Authorization: Bearer hck_…`) and your user's id. Same
`externalUserId` = same conversation, on every device. Expose it to the app as,
for example, `GET /me/halochat-token?refresh=1` behind your own login. See API.md
section 1.

## Route A (recommended): native chat screen through a platform channel

The Android and iOS SDKs in this folder include a ready-made chat screen
(attachments, retries, read ticks, notifications, English and Indonesian). From
Flutter, open it through a `MethodChannel`:

```dart
const haloChat = MethodChannel('halochat');
await haloChat.invokeMethod('setUser');   // after your login
await haloChat.invokeMethod('openChat');  // e.g. from a "Chat CS" button
await haloChat.invokeMethod('clearUser'); // on logout
```

Native side:

- **Android** (`halochat-android/README.md`): `HaloChatWidget.setup(...)` in your
  `Application`, then `setUser { forceRefresh -> <call your backend> }`,
  `initiateChat().startChat(context)` and `clearUser()`.
- **iOS** (`halochat-ios/README.md`): `HaloChatWidget(...)`,
  `setUser(tokenProvider:)`, `initiateChat().startChat { vc in present(vc) }`
  and `clearUser()`.

The token provider calls your backend endpoint above. It gets
`forceRefresh = true` when HaloAI refuses the current token: mint a new one.

Install: Android via JitPack (`com.github.afgventura.halochat-android:halochat-ui:0.2.1`),
iOS via Swift Package Manager or CocoaPods (`HaloChat/UI`, `0.2.0`). The same source
is in this folder.

## Route B: your own Flutter UI on the API

Every HaloChat feature is plain HTTPS + WebSocket, so Flutter can call API.md
directly and draw its own screen. The iOS/Android folders show the same logic in
Swift/Kotlin.

### Packages

| Need | Package |
|---|---|
| REST calls | `http` (or `dio`) |
| Realtime | `web_socket_channel` |
| Push | `firebase_messaging` |
| Idempotency keys | `uuid` |

### Rules the native SDKs handle for you (implement these)

- **401 on any call** → ask your backend for a new token, retry once.
- **Merge messages by `id`**, never append blindly. `after=` pages deliberately
  repeat up to 10 s of messages, and socket events can repeat history.
- **After every socket (re)connect**, backfill with `GET messages?after=<newestCursor>`.
  The socket has no replay.
- **Socket close codes:** `4001` → new token, reconnect. `4503`, `4029`, `4008` →
  reconnect with backoff using the same token.
- **Send** with one `Idempotency-Key` (UUID) per message. On timeout, resend with
  the SAME key. `409` → re-read messages, then retry.
- **429** → wait `Retry-After` seconds.
- Open the socket only while the chat screen is visible. If it cannot connect,
  poll `GET messages?after=` every 5 s. Background delivery is push.

### Push

Register after each sign-in: `POST /api/client/inApp/v1/devices`
`{ "platform": "android" | "ios", "pushToken": "..." }`

- Android: `await FirebaseMessaging.instance.getToken()`
- **iOS: `await FirebaseMessaging.instance.getAPNSToken()`**, the APNs device token,
  NOT the FCM token. HaloAI sends to iOS through APNs directly.

On sign-out: `DELETE /api/client/inApp/v1/devices?pushToken=...`, then
`DELETE /api/client/inApp/v1/session`.

Notification data: `{ type: "halochat_message", roomId, messageId }`. On tap, open
the chat screen (it backfills).

### Minimal Dart example

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const base = 'https://www.haloai.co.id/api/client/inApp/v1';

class HaloChat {
  HaloChat(this.fetchToken); // calls YOUR backend; force=true after a 401
  final Future<String> Function({bool force}) fetchToken;
  String? _token;
  String? newestCursor;
  final Map<String, Map<String, dynamic>> messages = {}; // merged by id

  Future<http.Response> _call(String method, String path,
      {Object? body, Map<String, String>? headers, bool retried = false}) async {
    _token ??= await fetchToken(force: false);
    final req = http.Request(method, Uri.parse('$base$path'))
      ..headers.addAll({
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
        ...?headers,
      });
    if (body != null) req.body = jsonEncode(body);
    final res = await http.Response.fromStream(await req.send());
    if (res.statusCode == 401 && !retried) {
      _token = await fetchToken(force: true);
      return _call(method, path, body: body, headers: headers, retried: true);
    }
    return res;
  }

  /// First call: newest page. Later calls: only newer messages.
  Future<void> load() async {
    final q = newestCursor == null ? '' : '?after=${Uri.encodeQueryComponent(newestCursor!)}';
    final res = await _call('GET', '/messages$q');
    final data = jsonDecode(res.body)['data'];
    for (final m in data['messages']) {
      messages[m['id']] = m;
    }
    newestCursor = data['newestCursor'] ?? newestCursor;
  }

  Future<void> send(String text, {String? key}) async {
    final res = await _call('POST', '/messages',
        body: {'text': text},
        headers: {'Idempotency-Key': key ?? const Uuid().v4()});
    final m = jsonDecode(res.body)['data']['message'];
    messages[m['id']] = m;
  }

  /// Foreground realtime. Reconnect on close (see close codes above).
  Future<WebSocketChannel> connect() async {
    _token ??= await fetchToken(force: false);
    final ws = WebSocketChannel.connect(Uri.parse('wss://conn3.haloai.co.id/ws/client'));
    ws.stream.listen((raw) async {
      final e = jsonDecode(raw);
      switch (e['type']) {
        case 'connected':
          ws.sink.add(jsonEncode({'type': 'auth', 'token': _token}));
        case 'authenticated':
          await load(); // backfill: the socket has no replay
        case 'message':
          messages[e['message']['id']] = e['message'];
        case 'message_deleted':
          messages.remove(e['id']);
      }
    });
    return ws;
  }
}
```

Sort `messages.values` by `createdAt` to render. `sender` is `me` or `agent`;
`senderKind` is `customer | ai | human | system`.
