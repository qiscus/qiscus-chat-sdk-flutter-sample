import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import 'app_state.dart';

class RoomState extends ChangeNotifier {
  RoomState({@required this.appState});

  final AppState appState;

  QiscusSDK get qiscus => appState.qiscus;

  int get currentRoomId => currentRoom?.id;
  QChatRoom _currentRoom;

  QChatRoom get currentRoom => _currentRoom;

  set currentRoom(QChatRoom room) {
    _currentRoom = room;
    notifyListeners();
  }

  var _rooms = <QChatRoom>[];

  List<QChatRoom> get rooms => _rooms;

  set rooms(List<QChatRoom> rooms) {
    _rooms = rooms;
    notifyListeners();
  }

  Future<QChatRoom> getRoomWithUser({@required String userId}) async {
    final completer = Completer<QChatRoom>();
    qiscus.chatUser(
      userId: userId,
      callback: (room, error) {
        if (error != null) {
          completer.completeError(error);
        } else {
          completer.complete(room);
        }

        currentRoom = room;
        rooms.add(room);
      },
    );
    return completer.future;
  }

  Future<QChatRoom> getRoomWithId(int roomId) async {
    final completer = Completer<QChatRoom>();
    qiscus.getChatRoomWithMessages(
      roomId: roomId,
      callback: (room, error) {
        if (error != null) return completer.completeError(error);
        currentRoom = room;
        completer.complete(room);
      },
    );
    return completer.future;
  }
}
