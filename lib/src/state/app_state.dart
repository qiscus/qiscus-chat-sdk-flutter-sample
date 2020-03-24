import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

class AppState extends ChangeNotifier {
  AppState();

  final qiscus = QiscusSDK();

  QAccount _account;

  set account(QAccount account) {
    _account = account;
    notifyListeners();
  }

  QAccount get account => _account;

  bool get isLoggedIn => account != null;

  String get userId => account?.id;

  Future<void> setup(String appId) {
    var completer = Completer<void>();
    qiscus.setup(appId, callback: (error) {
      if (error != null)
        completer.completeError(error);
      else
        completer.complete();
    });
    return completer.future;
  }

  Future<QAccount> setUser(String userId, String userKey) {
    var completer = Completer<QAccount>();
    qiscus.setUser(
      userId: userId,
      userKey: userKey,
      callback: (user, error) {
        if (error != null) {
          completer.completeError(error);
        } else {
          this.account = user;
          completer.complete(user);
        }
      },
    );
    return completer.future;
  }
}
