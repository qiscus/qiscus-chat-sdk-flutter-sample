import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

part 'app_state.g.dart';

class AppState = AppStateBase with _$AppState;

abstract class AppStateBase with Store {
  final qiscusSdk = QiscusSDK();

  @observable
  QAccount currentUser;

  @computed
  bool get isLoggedIn => currentUser != null;
  @computed
  String get userId => currentUser?.id ?? 'null';

  @action
  Future<void> setup(String appId) {
    var completer = Completer<void>();
    qiscusSdk.setup(appId, callback: (_) => completer.complete());
    return completer.future;
  }

  @action
  Future<QAccount> setUser({
    @required String userId,
    @required String userKey,
  }) {
    var completer = Completer<QAccount>();
    qiscusSdk.setUser(
      userId: userId,
      userKey: userKey,
      callback: (user, error) {
        if (error != null) {
          completer.completeError(error);
        } else {
          this.currentUser = user;
          completer.complete(user);
        }
      },
    );
    return completer.future;
  }
}
