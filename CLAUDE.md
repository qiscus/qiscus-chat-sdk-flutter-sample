# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A sample Flutter chat app demonstrating the `qiscus_chat_sdk` package (real-time messaging, MQTT + REST sync, Firebase push). It's used as a reference/debugging harness for SDK issues, not a production app.

## Commands

```bash
flutter pub get                              # install deps
flutter run --dart-define=QISCUS_APP_ID=xxx  # run app (App ID required, see below)
flutter analyze                              # lint (flutter_lints, analysis_options.yaml)
flutter build apk / build ios                # release builds
```

There are no automated tests in this repo (no `*_test.dart` files). Verification is manual: run on device/emulator and drive the chat flows described in FIX_NOTES/tickets.

## App ID handling

The Qiscus App ID is **never hardcoded**. It's read via `const appId = String.fromEnvironment('QISCUS_APP_ID')` in `lib/services/qiscus_service.dart` and the app throws on startup if it's empty. Always run/build with `--dart-define=QISCUS_APP_ID=<id>`. Never commit a real client App ID into source, docs, or commit messages.

## Architecture

- **`QiscusService`** (`lib/services/qiscus_service.dart`) — singleton wrapper around the `qiscus_chat_sdk` package. Owns the SDK instance and re-exposes every SDK callback as a broadcast `Stream` (`onMessageReceived`, `onMessageDelivered`, `onMessageRead`, `onMessageDeleted`, `onUserTyping`, `onUserPresence`, `onConnected`, `onReconnecting`). Providers subscribe to these streams rather than touching the SDK directly. Also owns `forceSynchronize()`, a wrapper around the SDK's public `sdk.synchronize()` used to force a REST resync (mitigation for MQTT subscribe races — see Known SDK quirks below).
- **Providers** (`lib/providers/`) use `ChangeNotifier` + `package:provider` for state:
  - `AuthProvider` — login (credentials/JWT), persisted session, logout.
  - `ChatProvider` — chat room list, current room, messages, typing/presence maps, upload progress, unread counts. Subscribes to `QiscusService` streams in its constructor and tears them down in `dispose()`. Has a `_roomSession` counter to guard against stale async callbacks landing after the user has navigated to a different room.
- **`main.dart`** — `MyApp` is a `StatefulWidget` with `WidgetsBindingObserver`; on `AppLifecycleState.resumed` it calls `forceSynchronize()` and re-subscribes the active room. This exists specifically to paper over a real-time delivery gap after backgrounding (Android especially — see below).
- **Screens** (`lib/screens/`) are straightforward Provider-consumer widgets: splash → login → home (chat list / create chat / profile) → chat room.

## Known SDK quirks (informs why the app code looks the way it does)

Investigated by reading the `qiscus_chat_sdk` package source directly in `~/.pub-cache` (the hosted docs site at documentation.qiscus.com is frequently unreachable — prefer reading pub-cache source over trying docs when investigating SDK behavior):

- `subscribeChatRoom()` only subscribes to `messageRead`/`messageDelivered`/`typing` topics, **not** new-message topics — resubscribing on reconnect does not fix missed incoming messages.
- The `messageNew` MQTT topic is subscribed exactly once, inside `_connectMqtt()`, which only runs on initial login — it is never re-run on MQTT reconnect.
- That initial subscribe is gated by `_doOnConnected()`, which waits for MQTT connection with a **1-second timeout and a silent `catch(_){}`** (no retry/backoff). If the MQTT handshake takes >1s (common on Android emulators/devices due to TLS/DNS/radio latency), new-message subscription silently never happens for the rest of the session.
- No MQTT keepalive is configured, so the socket can go "zombie" during Android Doze/App Standby without a detected disconnect.
- This is why the app-level mitigations exist: shorter `syncInterval`/`syncIntervalWhenConnected` via `setupWithCustomServer`, `forceSynchronize()` called ~2s after login and on app resume, and explicit `INTERNET`/`ACCESS_NETWORK_STATE` permissions in `AndroidManifest.xml`.
- These are sample-app-level workarounds, not SDK fixes — the underlying `_doOnConnected()` timeout/silent-catch and one-shot `_connectMqtt()` behavior are SDK issues to escalate to the SDK team, not something fixable from this repo.

## Working notes

- `FIX_NOTES_19727.txt`-style local investigation files are intentionally gitignored (`*.txt` in `.gitignore`) — treat any such file you find as local scratch/history, not something to commit.
- Two git remotes exist: `origin` (upstream `qiscus/...`) and `fathullahqiscus` (fork). Push only to `fathullahqiscus` unless explicitly told otherwise.
