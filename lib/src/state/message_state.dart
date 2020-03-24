import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:qiscus_chat_sample/src/state/room_state.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import 'app_state.dart';

class MessageState extends ChangeNotifier {
  MessageState({
    @required this.appState,
    @required this.roomState,
  });

  final AppState appState;
  final RoomState roomState;

  QiscusSDK get qiscus => appState.qiscus;

  List<QMessage> _messages = <QMessage>[];

  set messages(List<QMessage> messages) {
    _messages = messages;
    notifyListeners();
  }

  List<QMessage> get messages => _messages;

  Future<QMessage> submit({
    @required int roomId,
    @required String message,
  }) async {
    var nextMessage = QMessage.create(
      text: message,
      chatRoomId: roomId,
      sender: appState.account.asUser(),
    );
    this.messages.insert(0, nextMessage);
    notifyListeners();

    var completer = Completer<QMessage>();

    qiscus.sendMessage(
      message: nextMessage,
      callback: (message, error) {
        if (error != null) return completer.completeError(error);

        var index = this
            .messages //
            .indexWhere((m) => m.uniqueId == nextMessage.uniqueId);
        this.messages[index] = message;
        notifyListeners();
        // this.messages.removeAt(index);
        // this.messages.insert(index, message);

        completer.complete(message);
      },
    );
    return completer.future;
  }

  Future<List<QMessage>> getAllMessage(int roomId) async {
    var completer = Completer<List<QMessage>>();
    qiscus.getNextMessagesById(
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
          notifyListeners();

          completer.complete(messages);
        }
      },
    );

    return completer.future;
  }

  void subscribeChatRoom({void Function() messageReceivedCallback}) {
    qiscus.subscribeChatRoom(roomState.currentRoom);
    qiscus.onMessageDelivered((msg) {
      print('on message delivered: $msg');
    });
    qiscus.onMessageRead((msg) {
      print('on message read: $msg ${msg.uniqueId}');
      // Find a better way to update list item
      // and update previous messages which are not read.
      var index = this.messages.indexWhere((m) => m.uniqueId == msg.uniqueId);

      var message = this.messages.elementAt(index);
      message.status = QMessageStatus.read;
      this.messages[index] = message;
      // this.messages.removeAt(index);
      // this.messages.insert(index, message);
      notifyListeners();
    });
    qiscus.onMessageReceived((msg) {
      print('on message received: $msg ${msg.uniqueId}');
      messageReceivedCallback?.call();
      var index = this.messages.indexWhere((m) => m.uniqueId == msg.uniqueId);
      if (index == -1) {
        this.messages.insert(0, msg);
        notifyListeners();
      }
    });
  }

  @override
  dispose() {
    super.dispose();
    this.messages.clear();
  }
}
