import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';
import 'package:qiscus_chat_sdk/extension.dart';

class AppState extends ChangeNotifier {
  static Future<void> onBackgroundMessage(Map<String, dynamic> json) async {
//    print('fbMessaging::@background-message -> $json');
  }

  AppState() {
//    qiscus.enableDebugMode(enable: true, level: QLogLevel.verbose);
    fbMessaging.configure(
      onMessage: (Map<String, dynamic> json) async {
//        var value = JsonEncoder().convert(json);
//        debuPrint('fbMessaging@message -> $value');
      },
      onLaunch: (Map<String, dynamic> json) async {
        print('----> onLaunch: $json');
      },
      onResume: (Map<String, dynamic> json) async {
        print('----> onResume: $json');
      },
    );
    fbMessaging.requestNotificationPermissions();
  }

  final fbMessaging = FirebaseMessaging();
  final qiscus = QiscusSDK();

  String token;
  QAccount _account;

  set account(QAccount account) {
    _account = account;
    notifyListeners();
  }

  QAccount get account => _account;

  bool get isLoggedIn => account != null;

  String get userId => account?.id;

  Future<void> setup(String appId) async {
//    qiscus.enableDebugMode(enable: true, level: QLogLevel.verbose);
    qiscus.enableDebugMode(enable: true);
    await qiscus.setup$(appId);
  }

  Future<QAccount> _setUser(String userId, String userKey) async {
    var account = await qiscus.setUser$(
      userId: userId,
      userKey: userKey,
    );
    this.account = account;

    return account;
  }

  Future<void> _registerFcmToken() async {
    var token = await fbMessaging.getToken();
    print('FCM Token ---> $token');
    this.token = token;

    await qiscus.registerDeviceToken$(token: token);
  }

  Future<QAccount> setUser(String userId, String userKey) async {
    var account = await _setUser(userId, userKey);
    await _registerFcmToken();
    return account;
  }

  Future<void> signOut() async {
    await qiscus.removeDeviceToken$(token: this.token);
    await qiscus.clearUser$();
  }

  @override
  void dispose() {
    super.dispose();
    signOut().catchError(() {
      // do nothing
    });
  }
}
