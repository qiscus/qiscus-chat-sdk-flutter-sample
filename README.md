# Qiscus Chat SDK Flutter Sample

A reference implementation for integrating `qiscus_chat_sdk` into a Flutter
application. The project prioritizes an easy-to-follow core chat flow.

This is a debugging and integration sample, not a drop-in production chat app.

## Requirements

- Flutter 3.22 or newer
- Dart 3.4 or newer
- Qiscus App ID
- Android or iOS device/simulator

The project currently uses `qiscus_chat_sdk` 2.2.4. Android and iOS are the
official sample targets. The macOS runner is experimental.

## Quick start

```sh
flutter pub get
flutter run --dart-define=QISCUS_APP_ID=<your-app-id>
```

The App ID is required and must not be hardcoded in source. If it is missing,
the app displays an actionable configuration screen.

SDK HTTP logging is disabled by default because verbose logs can contain
authentication headers. Enable it only for local debugging:

```sh
flutter run \
  --dart-define=QISCUS_APP_ID=<your-app-id> \
  --dart-define=QISCUS_SDK_DEBUG=true
```

Never include real client App IDs, user keys, identity tokens, or SDK logs in
commits and tickets.

## Optional Firebase push

Core chat compiles and runs without Firebase configuration. To demonstrate
push notifications:

1. Configure the Android and iOS apps with FlutterFire or add the appropriate
   `google-services.json` and `GoogleService-Info.plist`.
2. Ensure APNs capabilities and provisioning are configured for iOS.
3. Run with push enabled:

```sh
flutter run \
  --dart-define=QISCUS_APP_ID=<your-app-id> \
  --dart-define=ENABLE_FIREBASE_PUSH=true
```

When enabled, the sample requests notification permission after login,
registers the current token with Qiscus, handles token refresh, and unregisters
the token before logout. Debug/profile builds register development tokens;
release builds register production tokens.

## Architecture

```text
screens
       ↓
AuthProvider / ChatProvider
       ↓
  QiscusGateway
       ↓
  QiscusService
       ↓
   QiscusSDK
```

- `QiscusService` owns the SDK instance and adapts SDK callbacks into broadcast
  streams. Its `QiscusGateway` interface makes provider behavior testable.
- `AuthProvider` owns session state. It relies on the SDK's persisted session
  and never stores user keys or identity tokens in `SharedPreferences`.
- `ChatProvider` owns room/message state, unread reconciliation, realtime
  subscriptions, pagination, upload progress, typing, and presence.
- `PushService` isolates optional Firebase initialization and token lifecycle.

Async room work is guarded by a room-session identifier. Results from a room
that has already been closed cannot update the newly active room. Timers and
stream subscriptions are cancelled during teardown.

## Demonstrated features

### Core flow

- Credential login and identity-token login
- SDK session restoration and logout
- Profile updates
- Paginated chat-room list and unread counts
- One-to-one, group, and channel creation
- Text and file messages with upload progress
- Message history pagination
- Delivered/read status updates
- Edit, delete, and clear-message actions
- Debounced read receipts and typing events
- Participant presence
- Add/remove group participants
- Reconnect, background/resume synchronization, and room resubscription
- Optional Firebase push-token lifecycle

## Verification

```sh
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug --dart-define=QISCUS_APP_ID=sample
flutter build ios --no-codesign --dart-define=QISCUS_APP_ID=sample
```

Automated tests use a fake `QiscusGateway`; no network credentials are needed.
End-to-end SDK verification still requires a valid App ID and two test users.

Recommended two-device smoke test:

1. Log in as two different users.
2. Create/open a one-to-one room.
3. Send text and file messages in both directions.
4. Verify typing, presence, unread, delivered, and read state.
5. Edit and delete an outgoing message.
6. Background one device, send messages, then resume it.
7. Disconnect/reconnect networking and verify REST synchronization recovers.
8. If Firebase is enabled, verify foreground/background push and token removal
   on logout.

## Known SDK behavior

Version 2.2.4 can miss the initial new-message MQTT subscription when the MQTT
handshake exceeds its internal timeout, and reconnect does not recreate that
subscription. The sample therefore keeps the following app-level mitigations:

- Shorter disconnected and connected REST sync intervals
- Forced synchronization shortly after login and on app resume
- Active-room resubscription on reconnect/resume
- Debounced `markAsRead` with bounded retry for rate limiting

These are defensive sample workarounds, not replacements for an SDK-level fix.

## Troubleshooting

- **Configuration screen on startup:** pass `QISCUS_APP_ID` with
  `--dart-define`.
- **Push unavailable:** add platform Firebase configuration and enable
  `ENABLE_FIREBASE_PUSH`.
- **Image picker closes on iOS:** confirm Photo Library permission exists in the
  built target.
- **Messages delayed after reconnect:** inspect SDK connection logs and trigger
  an app resume to force synchronization while investigating.
- **429 from `update_comment_status`:** keep read-receipt debounce enabled and
  inspect server-side request volume.

For Qiscus SDK issues, use the Qiscus support channel or the SDK issue tracker.
Do not publish security-sensitive logs in public issues.
