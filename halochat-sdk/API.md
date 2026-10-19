# HaloChat in-app API

HaloChat lets your own Android/iOS app put its logged-in users in a chat with your
CS team (HaloAI's AI agent + your human agents). The SDKs in this folder wrap this
API. A Flutter app can also call it directly (see FLUTTER.md).

```
Your backend ---hck_---> POST /api/open/inApp/v1/clientToken  -> hct_ token (per user, per device)
Your app -------hct_---> /api/client/inApp/v1/conversation | messages
```

Base URL: `https://www.haloai.co.id`

**Never put the server key in the app.** The channel's server key (`hck_…`) is a
backend credential: it mints tokens for any user of the channel. The app only ever
holds an `hct_` client token, which reaches exactly one user's conversation and expires.

## The channel server key

The HaloAI team creates your app channel and sends you its server key
(`hck_<channel id>.<secret>`) privately.

- Keep it in your server's secret store. It works for this channel only.
- If it leaks, ask the HaloAI team to regenerate it. The old key stops working at
  once and every app user is signed out of chat. The SDKs re-mint through your
  backend on the next `401`, so users reconnect once your backend holds the new key.

## 1. Mint a client token (business backend)

`POST /api/open/inApp/v1/clientToken`

| Header | Value |
|---|---|
| `Authorization` | `Bearer hck_…` (the channel's server key) |

```json
{
  "externalUserId": "staff-12345",
  "displayName": "Budi Santoso",
  "phone": "6281234567890",
  "ttlSeconds": 2592000
}
```

- `channelId`: optional; the key already names its channel. If sent, it must be
  that channel (anything else is `404`).
- `externalUserId`: your stable user id, 1–128 chars of `A-Z a-z 0-9 . _ : @ -`.
  The same id always maps to the same conversation, on every device.
- `displayName`, `phone`: optional, shown to agents (the first mint names the room).
- `ttlSeconds`: 3600–2592000, default 2592000 (30 days).

`200 { "status": "ok", "data": { "token": "hct_…", "expiresAt": "…", "roomId": "…" } }`

Errors: `400` invalid body, `401 invalid_server_key` (unknown, regenerated or
malformed key), `404` the channel was deleted or `channelId` is not the key's
channel.

Mint after your own login succeeds and hand the token to the app. Each mint is a
separate session (one per device login); older tokens stay valid until they expire
or are revoked.

### Revoke a user's tokens (business backend)

`POST /api/open/inApp/v1/revokeUser` (same headers as minting) with
`{ "externalUserId" }` (`channelId` optional, as above) → `200 { "data": { "revoked": <count> } }`.
Use it when an account is deleted, a device is lost, or you force a sign-out.
The user's conversation history is kept; a later mint reaches the same room.

## 2. Client endpoints (the app)

All take `Authorization: Bearer hct_…`. Any problem with the token (unknown,
tampered, expired, channel removed) is the same `401 {"error":"invalid_token"}`:
**on 401, ask your backend to mint a new token and retry once.**

Rate limits per token, per 60 s: 120 reads, 20 sends → `429` with `Retry-After`.

### `DELETE /api/client/inApp/v1/session`

Sign-out: expires the calling token. Call it before discarding the token.

### `GET /api/client/inApp/v1/conversation`

`200 { "data": { "roomId": "…", "title": "<channel label>" } }`

### `GET /api/client/inApp/v1/messages`

| Query | Meaning |
|---|---|
| (none) | newest page |
| `after=<newestCursor>` | newer messages (polling) |
| `before=<oldestCursor>` | older page (scroll back) |
| `limit` | 1–100, default 50 |

`after` and `before` are mutually exclusive. Cursors are opaque; store and send
them back verbatim.

```json
{
  "status": "ok",
  "data": {
    "messages": [
      {
        "id": "…",
        "text": "halo",
        "sender": "me",
        "senderKind": "customer",
        "hasMedia": false,
        "mediaType": null,
        "mediaFilename": null,
        "createdAt": "2026-09-29T08:00:00.000Z",
        "status": "read"
      }
    ],
    "newestCursor": "…",
    "oldestCursor": "…"
  }
}
```

- Messages are ascending by time. `sender` is `me` (the app user) or `agent`
  (business side); `senderKind` is `customer | ai | human | system`.
- `status` on **your user's** messages: `delivered` = received by the business,
  `read` = an agent opened the conversation. On agent messages it is `delivered`.
- `hasMedia: true` with `text: null` is an attachment: fetch it through the media
  endpoint. Interactive components (product cards, buttons) are not part
  of v1; they arrive as their text fallback when one exists.
- Internal control rows (hand-over markers, "no reply needed") never appear.
- **`after` pages also re-send up to 10 s of messages at or just before the
  cursor on purpose** (a message can commit slightly out of order). Always merge
  by `id`; never append blindly. `newestCursor` only ever moves forward, so
  polling always progresses however small `limit` is.

### `POST /api/client/inApp/v1/messages`

Headers: `Idempotency-Key: <one UUID per logical message>` (8–200 chars).
Body: `{ "text": "…" }` (1–4096 chars after trimming).

`200 { "data": { "message": { …ClientMessage, "sender": "me" } } }`

The reply (AI or human) is **not** in this response; it arrives in the
conversation afterwards.

**Retry rule:** with the same `Idempotency-Key`, a resend is safe and returns the
same message (24 h). A new key is a new message. A `409` means the first attempt
is still running; re-read the conversation before retrying.

### Attachments

1. `POST /api/client/inApp/v1/uploads` `{ "filename", "mimeType", "sizeBytes" }` →
   `{ "uploadId", "uploadUrl", "uploadHeaders": {"Content-Type": …}, "maxBytes" }`.
2. `PUT <uploadUrl>` with the bytes and the returned headers.
3. `POST /api/client/inApp/v1/messages` `{ "uploadId": "…", "text": "optional caption" }`
   (same `Idempotency-Key` rule as text).

Limits: 25 MB; images (jpeg, png, webp, gif, heic), video (mp4, mov), audio (mp3, m4a,
aac, ogg), pdf, Word/Excel (.docx/.xlsx only), plain text. Each upload URL is
write-once: upload again (new `uploads` call) instead of re-PUTting.
Size and type are checked on the stored file
(`upload_too_large`, `upload_type`, `upload_missing` → 400).

`GET /api/client/inApp/v1/media/{messageId}` → `{ "url", "expiresAt" }`: a download URL
valid for 15 minutes for any attachment in the conversation (yours or the agent's).
Fetch a new one instead of caching the URL.

## 3. Receiving replies

### Realtime socket (foreground)

`wss://conn3.haloai.co.id/ws/client`

```
server: {"type":"connected"}
client: {"type":"auth","token":"hct_…"}                  (within 10 s)
server: {"type":"authenticated","roomId":"…"}
server: {"type":"message","message":{…ClientMessage}}    (new message or an update, e.g. status)
server: {"type":"message_deleted","id":"…"}
server: {"type":"heartbeat","timestamp":…}               (+ a WS ping; clients answer automatically)
```

- The socket follows exactly one room: the token's. It never carries other
  rooms or any staff data, and messages use the same `ClientMessage` shape as
  the REST history.
- Close codes:
  - **4001** (`invalid_token`, `token_expired`, `token_revoked`, `auth_required`,
    `auth_timeout`): mint a fresh token, then reconnect. The server re-checks the
    token every 5 minutes (so a revoked or rotated-out session's open socket closes
    within 5 minutes) and closes the socket at `expiresAt`.
  - **4503** `auth_unavailable`: HaloAI could not verify the token right now;
    reconnect with backoff using the **same** token (do not mint).
  - **4029** `too_many_connections` (max 5 sockets per conversation) and
    **4008** `backpressure`: reconnect with backoff.
- **The socket has no replay.** After every (re)connect, backfill with
  `GET messages?after=<newestCursor>` and merge by `id`, then keep merging
  socket events by `id` (an event can repeat a message already in history).
- Connect only while the chat UI is in the foreground; background delivery is
  push.

### Polling fallback

If the socket cannot connect, poll `GET messages?after=<newestCursor>` every
5 s while the chat screen is in the foreground and merge by `id`.

### Push (background)

Setup, once per app: send the HaloAI team your **own** Firebase service-account JSON (Android)
and/or APNs `.p8` key + Key ID + Team ID + bundle id (iOS), and say whether the iOS build is
App Store/TestFlight or a development build. HaloAI stores them encrypted.

The app registers each device after sign-in:

- `POST /api/client/inApp/v1/devices` `{ "platform": "android" | "ios", "pushToken": "…" }`
  (FCM registration token, or the APNs device token as hex).
- `DELETE /api/client/inApp/v1/devices?pushToken=…` on sign-out.

A device receives the user's pushes while the user has **any** live session
(a re-minted token keeps pushes flowing). `DELETE /session` (sign-out) removes that
device's registrations; `revokeUser` expires every session and so stops all pushes.
Register after each sign-in; the SDKs also re-register after they re-mint a token. Every outbound message (AI, human, automation; not
internal markers or "please hold" bubbles) is pushed once:

- FCM: `notification {title: <channel label>, body: <preview>}`, `data {type: "halochat_message", roomId, messageId}`.
- APNs: `aps.alert {title, body}`, `thread-id: roomId`, plus `type`, `roomId`, `messageId`.

Tapping the notification should open the chat and start the timeline (it backfills).
The notification title is the business name. Each message is its own notification;
group them client-side by `roomId` if you prefer. A message sent before the user has
ever written (the conversation is not open yet) is not pushed.

