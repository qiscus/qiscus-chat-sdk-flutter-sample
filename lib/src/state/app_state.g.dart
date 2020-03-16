// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AppState on AppStateBase, Store {
  Computed<bool> _$isLoggedInComputed;

  @override
  bool get isLoggedIn =>
      (_$isLoggedInComputed ??= Computed<bool>(() => super.isLoggedIn)).value;
  Computed<String> _$userIdComputed;

  @override
  String get userId =>
      (_$userIdComputed ??= Computed<String>(() => super.userId)).value;

  final _$currentUserAtom = Atom(name: 'AppStateBase.currentUser');

  @override
  QAccount get currentUser {
    _$currentUserAtom.context.enforceReadPolicy(_$currentUserAtom);
    _$currentUserAtom.reportObserved();
    return super.currentUser;
  }

  @override
  set currentUser(QAccount value) {
    _$currentUserAtom.context.conditionallyRunInAction(() {
      super.currentUser = value;
      _$currentUserAtom.reportChanged();
    }, _$currentUserAtom, name: '${_$currentUserAtom.name}_set');
  }

  final _$AppStateBaseActionController = ActionController(name: 'AppStateBase');

  @override
  Future<void> setup(String appId) {
    final _$actionInfo = _$AppStateBaseActionController.startAction();
    try {
      return super.setup(appId);
    } finally {
      _$AppStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  Future<QAccount> setUser(
      {@required String userId, @required String userKey}) {
    final _$actionInfo = _$AppStateBaseActionController.startAction();
    try {
      return super.setUser(userId: userId, userKey: userKey);
    } finally {
      _$AppStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    final string =
        'currentUser: ${currentUser.toString()},isLoggedIn: ${isLoggedIn.toString()},userId: ${userId.toString()}';
    return '{$string}';
  }
}
