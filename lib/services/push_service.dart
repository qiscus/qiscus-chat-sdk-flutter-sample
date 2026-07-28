import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

const bool firebasePushEnabled =
    bool.fromEnvironment('ENABLE_FIREBASE_PUSH', defaultValue: false);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!firebasePushEnabled) return;
  try {
    await Firebase.initializeApp();
    _parsePayload(message);
  } catch (error, stackTrace) {
    debugPrint('Push background handling failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

Map<String, dynamic>? _parsePayload(RemoteMessage message) {
  final rawPayload = message.data['payload'];
  if (rawPayload == null || rawPayload.isEmpty) return message.data;

  try {
    final decoded = jsonDecode(rawPayload);
    return decoded is Map<String, dynamic> ? decoded : null;
  } on FormatException {
    debugPrint('Ignoring malformed push payload');
    return null;
  }
}

class PushService {
  PushService({
    FirebaseMessaging? messaging,
    this.enabled = firebasePushEnabled,
  }) : _messaging = messaging;

  final bool enabled;
  FirebaseMessaging? _messaging;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  QiscusSDK? _sdk;
  bool _initialized = false;
  bool get isAvailable => enabled && _initialized;

  Future<void> initialize() async {
    if (!enabled || _initialized) return;

    try {
      await Firebase.initializeApp();
      _messaging ??= FirebaseMessaging.instance;
      FirebaseMessaging.onBackgroundMessage(
        firebaseMessagingBackgroundHandler,
      );
      _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
        final payload = _parsePayload(message);
        debugPrint(
          payload == null
              ? 'Foreground push ignored'
              : 'Foreground push received',
        );
      });
      _initialized = true;
    } catch (error, stackTrace) {
      debugPrint(
        'Firebase push is unavailable. Add platform Firebase configuration '
        'before enabling ENABLE_FIREBASE_PUSH: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> registerForUser(QiscusSDK sdk) async {
    if (!_initialized || _messaging == null) return;
    _sdk = sdk;

    final settings = await _messaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await _messaging!.getToken();
    if (token != null) await _registerToken(token);

    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription =
        _messaging!.onTokenRefresh.listen(_registerToken);
  }

  Future<void> _registerToken(String token) async {
    final sdk = _sdk;
    if (sdk == null) return;
    try {
      await sdk.registerDeviceToken(
        token: token,
        isDevelopment: !kReleaseMode,
      );
    } catch (error) {
      debugPrint('Push token registration failed: $error');
    }
  }

  Future<void> unregisterCurrentToken() async {
    final sdk = _sdk;
    final messaging = _messaging;
    if (sdk != null && messaging != null) {
      try {
        final token = await messaging.getToken();
        if (token != null) {
          await sdk.removeDeviceToken(
            token: token,
            isDevelopment: !kReleaseMode,
          );
        }
      } catch (error) {
        debugPrint('Push token removal failed: $error');
      }
    }
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _sdk = null;
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _foregroundSubscription?.cancel();
  }
}
