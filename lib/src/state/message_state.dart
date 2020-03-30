import 'dart:async';
import 'dart:io';

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

        completer.complete(message);
      },
    );
    return completer.future;
  }

  /// Load more
  Future<List<QMessage>> getPreviousMessage(int roomId) async {
    var completer = Completer<List<QMessage>>();
    qiscus.getPreviousMessagesById(
      roomId: roomId,
      messageId: this.messages.last.id,
      callback: (List<QMessage> messages, Exception error) {
        if (error != null) return completer.completeError(error);

        this.messages.addAll(messages);

        Future.delayed(const Duration(seconds: 2), () {
          completer.complete(messages);
          notifyListeners();
        });
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
    qiscus.onMessageDelivered((msg) {
      for (var message in this.messages) {
        if (message.id <= msg.id && message.status != QMessageStatus.read) {
          message.status = QMessageStatus.delivered;
          var index = this.messages.indexOf(message);
          this.messages[index] = message;
        }
      }
      notifyListeners();
    });
    qiscus.onMessageRead((msg) {
      for (var message in this.messages) {
        if (message.id <= msg.id) {
          message.status = QMessageStatus.read;
          var index = this.messages.indexOf(message);
          this.messages[index] = message;
        }
      }
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

  Future<void> sendFile(File file) async {
    var completer = Completer<void>();
    var message = QMessage.createAttachment(
      text: 'attachment',
      chatRoomId: roomState.currentRoomId,
      sender: appState.account.asUser(),
      file: file,
    );
    qiscus.sendFileMessage(
      message: message,
      file: file,
      callback: (error, progress, message) {
        if (error != null) return completer.completeError(error);
        if (progress != null) return print('progress: $progress');

        message.status = QMessageStatus.sent;
        this.messages.insert(0, message);
        notifyListeners();
        completer.complete();
      },
    );
    return completer.future;
  }

  @override
  dispose() {
    super.dispose();
    this.messages.clear();
  }
}

class MessageActions {
  //
}
