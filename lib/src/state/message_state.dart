import 'dart:async';
import 'dart:collection';
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

  var _messages = HashMap<String, QMessage>(hashCode: (key) => key.hashCode);

  set messages(List<QMessage> messages) {
    _messages.addEntries(messages.map((m) => MapEntry(m.uniqueId, m)));
    notifyListeners();
  }

  List<QMessage> get messages => _messages.values.toList()
    ..sort((m1, m2) => m1.timestamp.compareTo(m2.timestamp));

  Future<QMessage> submit({
    @required int roomId,
    @required String message,
  }) async {
    var nextMessage = QMessage.create(
      text: message,
      chatRoomId: roomId,
      sender: appState.account.asUser(),
    );
    _messages.update(
      nextMessage.uniqueId,
      (_) => nextMessage,
      ifAbsent: () => nextMessage,
    );

    notifyListeners();

    var completer = Completer<QMessage>();

    qiscus.sendMessage(
      message: nextMessage,
      callback: (message, error) {
        if (error != null) return completer.completeError(error);

        _messages.update(
          message.uniqueId,
          (m) => message,
          ifAbsent: () => message,
        );
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
      limit: 10,
      callback: (List<QMessage> messages, Exception error) {
        if (error != null) return completer.completeError(error);

        _messages.addEntries(messages.map((m) => MapEntry(m.uniqueId, m)));

        completer.complete(messages);
        notifyListeners();
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
          _messages.addEntries(messages.map((m) => MapEntry(m.uniqueId, m)));

          notifyListeners();

          completer.complete(messages);
        }
      },
    );

    return completer.future;
  }

  void subscribeChatRoom({void Function() messageReceivedCallback}) {
    qiscus.onMessageDelivered((msg) {
      for (var message in _messages.values) {
        if (message.id <= msg.id && message.status != QMessageStatus.read) {
          message.status = QMessageStatus.delivered;

          _messages.update(
            message.uniqueId,
            (_) => message,
            ifAbsent: () => message,
          );
        }
      }
      notifyListeners();
    });
    qiscus.onMessageRead((msg) {
      for (var message in _messages.values) {
        if (message.id <= msg.id) {
          message.status = QMessageStatus.read;
          _messages.update(
            message.uniqueId,
            (_) => message,
            ifAbsent: () => message,
          );
        }
      }
      notifyListeners();
    });
    qiscus.onMessageReceived((msg) {
      messageReceivedCallback?.call();
      _messages.update(msg.uniqueId, (_) => msg, ifAbsent: () => msg);
      notifyListeners();
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

        _messages.update(
          message.uniqueId,
          (_) => message,
          ifAbsent: () => message,
        );

        notifyListeners();
        completer.complete();
      },
    );
    return completer.future;
  }

  @override
  dispose() {
    super.dispose();
  }
}

class MessageActions {
  //
}
