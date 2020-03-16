import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:qiscus_chat_sample/src/state/room_state.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import 'app_state.dart';

part 'message_state.g.dart';

class MessageState = MessageStateBase with _$MessageState;

abstract class MessageStateBase with Store {
  MessageStateBase({
    @required this.appState,
    @required this.roomState,
  });

  final AppState appState;
  final RoomState roomState;

  QiscusSDK get _qiscusSDK => appState.qiscusSdk;

  @observable
  ObservableList<QMessage> messages = ObservableList.of([]);

  @action
  Future<QMessage> submit({
    @required int roomId,
    @required String message,
  }) async {
    var nextMessage = QMessage.create(
      text: message,
      chatRoomId: roomId,
      sender: appState.currentUser.asUser(),
    );
    this.messages.insert(0, nextMessage);
    var completer = Completer<QMessage>();

    _qiscusSDK.sendMessage(
      message: nextMessage,
      callback: (message, error) {
        if (error != null) return completer.completeError(error);

        var index = this.messages.indexWhere(
              (m) => m.uniqueId == nextMessage.uniqueId,
            );
        this.messages.removeAt(index);
        this.messages.insert(index, message);
//        this.messages[index] = message;

        completer.complete(message);
      },
    );
    return completer.future;
  }

  @action
  Future<List<QMessage>> getAllMessage(int roomId) async {
    var completer = Completer<List<QMessage>>();
    _qiscusSDK.getNextMessagesById(
      roomId: roomId,
      messageId: 0,
      limit: 10,
      callback: (messages, error) {
        if (error != null) {
          completer.completeError(error);
          return print('error while getting message: $error');
        } else {
          this.messages.clear();
          this.messages.addAll(messages);

          completer.complete(messages);
        }
      },
    );

    return completer.future;
  }

  @action
  void subscribeChatRoom({void Function() messageReceivedCallback}) {
    _qiscusSDK.subscribeChatRoom(roomState.currentRoom);
    _qiscusSDK.onMessageDelivered((msg) {
      print('on message delivered: $msg');
    });
    _qiscusSDK.onMessageRead((msg) {
      print('on message read: $msg ${msg.uniqueId}');
      // Find a better way to update list item
      // and update previous messages which are not read.
      var index = this.messages.indexWhere((m) => m.uniqueId == msg.uniqueId);

      var message = this.messages.elementAt(index);
      message.status = QMessageStatus.read;
      this.messages.removeAt(index);
      this.messages.insert(index, message);
    });
    _qiscusSDK.onMessageReceived((msg) {
      print('on message received: $msg ${msg.uniqueId}');
      messageReceivedCallback?.call();
      var index = this.messages.indexWhere((m) => m.uniqueId == msg.uniqueId);
      if (index == -1) {
        this.messages.insert(0, msg);
      }
    });
  }

  dispose() {
    this.messages.clear();
  }
}
