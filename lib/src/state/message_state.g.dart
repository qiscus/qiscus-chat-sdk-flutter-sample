// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_state.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$MessageState on MessageStateBase, Store {
  final _$messagesAtom = Atom(name: 'MessageStateBase.messages');

  @override
  ObservableList<QMessage> get messages {
    _$messagesAtom.context.enforceReadPolicy(_$messagesAtom);
    _$messagesAtom.reportObserved();
    return super.messages;
  }

  @override
  set messages(ObservableList<QMessage> value) {
    _$messagesAtom.context.conditionallyRunInAction(() {
      super.messages = value;
      _$messagesAtom.reportChanged();
    }, _$messagesAtom, name: '${_$messagesAtom.name}_set');
  }

  final _$submitAsyncAction = AsyncAction('submit');

  @override
  Future<QMessage> submit({@required int roomId, @required String message}) {
    return _$submitAsyncAction
        .run(() => super.submit(roomId: roomId, message: message));
  }

  final _$getAllMessageAsyncAction = AsyncAction('getAllMessage');

  @override
  Future<List<QMessage>> getAllMessage(int roomId) {
    return _$getAllMessageAsyncAction.run(() => super.getAllMessage(roomId));
  }

  final _$MessageStateBaseActionController =
      ActionController(name: 'MessageStateBase');

  @override
  void subscribeChatRoom({void Function() messageReceivedCallback}) {
    final _$actionInfo = _$MessageStateBaseActionController.startAction();
    try {
      return super
          .subscribeChatRoom(messageReceivedCallback: messageReceivedCallback);
    } finally {
      _$MessageStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    final string = 'messages: ${messages.toString()}';
    return '{$string}';
  }
}
