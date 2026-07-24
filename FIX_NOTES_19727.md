# Fix Notes — Ticket #19727 "Qiscus Delay in Flutter"

Customer: Klikdokter SMB, appID `qchatsdk--ippqdracerp`

## 1. Laporan awal

Pesan masuk tidak realtime saat user berada di dalam chat room. Baru muncul setelah keluar-masuk room lagi. Network normal, data confirmed ada di server.

## 2. Root cause awal

`onMessageReceived()` = gabungan MQTT subscription + REST sync fallback (`realtime.dart:66-133`). Fallback polling:
- 5 detik kalau MQTT disconnected
- **30 detik** kalau MQTT sedang connected

Kalau MQTT status "connected" tapi diam-diam drop pesan room tertentu (QoS 0 loss / race saat reconnect) — dan tidak ada re-subscribe otomatis saat reconnect — pesan yang hilang baru ke-backfill lewat REST poll 30 detik itu. Sample app pakai `sdk.setup(appId)` default, jadi warisan gap 30 detik ini.

## 3. Fix gelombang 1 — sync interval & resubscribe

**File: `lib/services/qiscus_service.dart`**
- `sdk.setup(appId)` → `sdk.setupWithCustomServer(appId, syncInterval: 5000, syncIntervalWhenConnected: 5000)` — dari 30s jadi 5s
- Tambah stream `onConnected` / `onReconnecting` (dari `sdk.onConnected()`/`onReconnecting()`)

**File: `lib/providers/chat_provider.dart`**
- Listener baru: saat `onConnected`/`onReconnecting` fire dan `_currentRoom != null` → panggil ulang `subscribeChatRoom(_currentRoom!)`

**File: `pubspec.yaml`**
- Upgrade `qiscus_chat_sdk: ^2.2.1` → `^2.2.3` (versi terbaru pub.dev saat itu)

## 4. Testing manual — ditemukan masalah baru

Test di Android emulator (appId production) vs sample web: pesan **tidak muncul sama sekali** selama puluhan menit meski foreground terus, sementara test antar-browser aman/instant. Berarti ada root cause lain, khusus Android, yang gak ke-cover fix gelombang 1.

## 5. Investigasi mendalam ke source SDK (`qiscus_chat_sdk-2.2.3`)

Ditemukan lewat baca langsung `lib/src/qiscus.dart` di pub-cache:

- **`subscribeChatRoom()` (qiscus.dart:691-706) cuma subscribe topic `messageRead`/`messageDelivered`/`typing`** — BUKAN topic pesan baru. Jadi fix resubscribe di gelombang 1 gak nolong buat masalah "pesan gak masuk".
- Topic pesan baru (`messageNew`) di-subscribe **cuma sekali**, di dalam `_connectMqtt()` (qiscus.dart:675-689), yang cuma dipanggil sekali pas login — **tidak pernah dipanggil ulang saat reconnect**.
- Subscribe itu di-gate oleh `_doOnConnected()` (qiscus.dart:665-673): nunggu MQTT connected, tapi **timeout 1 detik dan silently swallow error** (`catch(_){}`, tanpa retry). Kalau handshake MQTT di Android > 1 detik (umum di emulator/HP karena TLS/DNS/radio), subscribe pesan baru gak pernah kejadian buat seluruh sesi — dan gak ada cara recover selain re-login.
- Tidak ada MQTT keepalive di-set (`core/mqtt.dart`), jadi socket "zombie" pas Doze/App Standby Android bisa gak kedeteksi disconnect.
- **`AndroidManifest.xml` gak punya permission `INTERNET` sama sekali** — kebetulan masih jalan di debug build karena Flutter Gradle plugin inject implisit, tapi gap nyata untuk release build.
- Web aman karena koneksi lokal/browser jauh lebih cepat, jarang miss window 1 detik itu.
- Ada API publik `sdk.synchronize()` (qiscus.dart:755-761) yang bisa dipanggil manual buat force REST resync — masuk langsung ke stream `onMessageReceived` yang sama.

## 6. Fix gelombang 2 — mitigasi level app (sample project, bukan ubah SDK)

**File: `lib/services/qiscus_service.dart`**
- Enable `sdk.enableDebugMode(enable: true, level: QLogLevel.verbose)` untuk diagnostic
- Tambah `forceSynchronize()` — wrapper `sdk.synchronize()` publik
- `loginWithCredentials` & `loginWithToken`: panggil `forceSynchronize()` otomatis 2 detik setelah login sukses — nutup celah race 1 detik di atas

**File: `lib/main.dart`**
- `MyApp` diubah jadi `StatefulWidget` + `WidgetsBindingObserver`
- Saat `AppLifecycleState.resumed`: panggil `forceSynchronize()` + resubscribe room aktif (kalau ada)

**File: `android/app/src/main/AndroidManifest.xml`**
- Tambah `<uses-permission android:name="android.permission.INTERNET"/>`
- Tambah `<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>`

## 7. Yang perlu di-escalate ke tim SDK (bukan bisa di-fix dari sample app)

- `_doOnConnected()` timeout 1 detik + silent catch di `qiscus.dart:665-673` — harusnya ada retry/backoff, bukan give up permanen
- `_connectMqtt()` cuma dipanggil sekali saat login, harusnya re-run juga saat MQTT reconnect biar `messageNew` subscribe ke-refresh
- Gak ada MQTT keepalive default

## 8. Status testing (per hari ini)

- ✅ Core fix — faster sync fallback
- ✅ Setup
- ✅ Baseline sanity
- [ ] Reconnect robustness (airplane mode toggle di dalam room)
- [ ] Background/resume test (minimize 30-60s, kirim pesan, resume, cek `📱 App resumed — forcing resync` + pesan masuk)
- [ ] Regression check (leave/re-enter room, typing indicator, read/delivered receipt)

## Referensi kode SDK (jangan diubah, cuma referensi)
- `qiscus.dart:665-673` — `_doOnConnected` race
- `qiscus.dart:675-706` — `_connectMqtt` vs `subscribeChatRoom` (beda scope topic)
- `qiscus.dart:755-761` — `synchronize()` publik
- `core/mqtt.dart` — no keepalive, `autoReconnect`
- `realtime.dart:31-133` — sync interval logic
