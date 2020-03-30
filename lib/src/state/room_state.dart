import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import 'app_state.dart';

class TypingState extends ChangeNotifier {
  //
}

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

        this.currentRoom = room;
        this.rooms.add(room);
        subscribeUser(userId);
      },
    );
    return completer.future;
  }

  Future<QChatRoom> getRoomWithId(int roomId) async {
    final completer = Completer<QChatRoom>();
    qiscus.getChatRoomWithMessages(
      roomId: roomId,
      callback: (room, messages, error) {
        if (error != null) return completer.completeError(error);
        this.currentRoom = room;
        completer.complete(room);
      },
    );
    return completer.future;
  }

  void subscribe(QChatRoom room) => qiscus.subscribeChatRoom(room);

  void unsubscribe(QChatRoom room) => qiscus.unsubscribeChatRoom(room);

  final _userSubscription = <String, bool>{};

  void subscribeUser(String userId) {
    if (_userSubscription.containsKey(userId)) return;
    qiscus.subscribeUserOnlinePresence(userId);
    _userSubscription[userId] = true;
  }

  final _typing$ = StreamController<Typing>.broadcast();

  Stream<Typing> get onTyping {
    Timer _timer;
    var unsubscribe = qiscus.onUserTyping((userId, roomId, isTyping) {
      if (_timer != null) _timer.cancel();
      _typing$.add(Typing(userId, roomId, isTyping));
      _timer = Timer(const Duration(seconds: 2), () {
        _typing$.add(Typing(userId, roomId, false));
      });
    });
    _typing$.onCancel = () => unsubscribe();
    return _typing$.stream.distinct();
  }

  final _online$ = StreamController<Online>.broadcast();

  Stream<Online> get onPresence {
    var unsubscribe = qiscus.onUserOnlinePresence(
      (userId, isOnline, lastOnline) {
        print('on presence: $userId $isOnline $lastOnline');
        _online$.add(Online(userId, isOnline, lastOnline));
      },
    );
    _online$.onCancel = () => unsubscribe();
    return _online$.stream.distinct();
  }

  @override
  dispose() {
    _typing$.close();
    _online$.close();
    _userSubscription.keys.forEach((userId) {
      print('unsubs user: $userId');
      qiscus.unsubscribeUserOnlinePresence(userId);
    });
    super.dispose();
  }
}

class Typing {
  const Typing(this.userId, this.roomId, this.isTyping);

  final String userId;
  final int roomId;
  final bool isTyping;
}

class Online {
  const Online(this.userId, this.isOnline, this.lastOnline);

  final String userId;
  final bool isOnline;
  final DateTime lastOnline;
}
