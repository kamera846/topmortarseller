# HaloChat SDK v0.2 (Top Mortar)

In-app chat between your app users and your HaloAI CS team (AI + human agents).
Conversations from the app land in your HaloAI "Livechat" inbox.

- halochat-android/  Kotlin library + drop-in chat screen (minSdk 21). See its README.
- halochat-ios/      Swift package / CocoaPod + drop-in chat screen (iOS 15+). See its README.
- API.md             REST + realtime API the SDKs wrap.
- FLUTTER.md         How to use HaloChat from a Flutter app (no Flutter package yet).

## Your channel

- Base URL:   https://www.haloai.co.id
- Channel ID: 01a12f5d-1f7b-7153-96ed-20fa1d3faa08 ("Top Mortar App")

## Step 1: generate the server key (once)

1. Log in to HaloAI with an account that can manage integrations.
2. Open https://www.haloai.co.id/b/l5vi6/integrations
3. Open the settings of the channel "Top Mortar App".
4. Open the "HaloChat" section.
5. Under "Server key", click "Generate server key" ("Buat server key").
6. Copy the key (it starts with hck_). It is shown only once.
7. Store it in your backend's secret store. Never put it in the app.

Lost or leaked: click "Regenerate" in the same place. The old key stops working at
once, and app users reconnect after your backend uses the new key.

## Step 2: backend mints a token per user

After your user logs in, your backend calls:

    POST https://www.haloai.co.id/api/open/inApp/v1/clientToken
    Authorization: Bearer <server key>
    {"externalUserId":"<your user id>","displayName":"<store name>","phone":"628..."}

Fill "phone" with the store's registered phone number, so the CS agent can find
the store's data. Return the "token" (hct_...) to the app. Details: API.md section 1.

## Step 3: app opens the chat

Flutter: see FLUTTER.md (route A opens the SDK's ready-made chat screen).

## Step 4: push notifications (optional)

Send the HaloAI team your Firebase service-account JSON (Android) and APNs .p8 key
+ Key ID + Team ID + bundle id (iOS).

Public repositories (same SDK source):
- https://github.com/afgventura/halochat-android
- https://github.com/afgventura/halochat-ios

Build: ec2050d238 (2026-10-12)
