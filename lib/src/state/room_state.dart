import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import 'app_state.dart';

part 'room_state.g.dart';

class RoomState = RoomStateBase with _$RoomState;

abstract class RoomStateBase with Store {
  RoomStateBase({@required this.appState});

  final AppState appState;
  QiscusSDK get _qiscusSDK => appState.qiscusSdk;

  @observable
  QChatRoom currentRoom;

  @observable
  var rooms = <QChatRoom>[];

  @computed
  int get currentRoomId => currentRoom?.id;

  Future<QChatRoom> getRoomWithUser({@required String userId}) async {
    final completer = Completer<QChatRoom>();
    _qiscusSDK.chatUser(
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
    _qiscusSDK.getChatRoomWithMessages(
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
