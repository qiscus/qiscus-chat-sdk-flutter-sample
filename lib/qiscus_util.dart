import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

class QiscusUtil extends ChangeNotifier implements ReassembleHandler {
  QiscusUtil(this.qiscus, {required this.logger});

  factory QiscusUtil.update(
    QiscusSDK qiscus, {
    required Logger logger,
    QiscusUtil? dis,
  }) {
    var it = QiscusUtil(qiscus, logger: logger);
    if (dis != null) {
      it.messages = dis.messages;
      it.rooms = dis.rooms;
      it.subs = dis.subs;
      it.account = dis.account;
      it.users = dis.users;
      it.typings = dis.typings;
      it.presences = dis.presences;
    }

    return it;
  }
  final QiscusSDK qiscus;
  final Logger logger;

  Set<QMessage> messages = {};
  Set<QChatRoom> rooms = {};
  List<StreamSubscription> subs = [];
  QAccount? account;
  Set<QUser> users = {};
  Set<QUserTyping> typings = {};
  Set<QUserPresence> presences = {};

  void Function(QChatRoom) get subscribeRoom => qiscus.subscribeChatRoom;
  void Function(QChatRoom) get unsubscribeRoom => qiscus.unsubscribeChatRoom;
  Future<bool> Function({required String token, bool? isDevelopment})
      get registerDeviceToken => qiscus.registerDeviceToken;
  Stream<QUploadProgress<String>> Function(File, {CancelToken? cancelToken})
      get upload => qiscus.upload;

  Future<void> setup(String appId) {
    // qiscus.enableDebugMode(enable: true, level: QLogLevel.verbose);

    return qiscus.setup(appId);
  }

  Future<QAccount?> setUser({
    required String userId,
    required String userKey,
    String? username,
    String? avatarUrl,
    Map<String, Object?>? extras,
  }) async {
    var account = await qiscus.setUser(
      userId: userId,
      userKey: userKey,
      username: username,
      extras: extras,
      avatarUrl: avatarUrl,
    );
    this.account = account;
    logger.d('logged in as $account');
    notifyListeners();

    return account;
  }

  QAccount? getCurrentUser()  {
    return qiscus.currentUser;
  }

  Future<void> readMessage(QChatRoom room, int lastMessageVisibleId)  async {
    await qiscus.markAsRead(roomId: room.id, messageId: lastMessageVisibleId);
    var data = await qiscus.getChatRoomWithMessages(roomId: room.id);
    room.unreadCount = data.room.unreadCount;
    debugPrint('last room unread update ${data.room}');
    notifyListeners();
  }

  String defaultAvatarUrl()  {
    return "https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50.jpg";
  }

  Future<void> getInitialMessages(QChatRoom room) async {
    var data = await qiscus.getChatRoomWithMessages(roomId: room.id);
    rooms.add(data.room);
    messages.addAll(data.messages);

    notifyListeners();
  }

  Future<List<QChatRoom>> getAllChatRooms() async {
    var rooms = await qiscus.getAllChatRooms(showParticipant: true);
    this.rooms.addAll(rooms);
    notifyListeners();

    return rooms;
  }

  Future<QAccount> updateUser({
    String? name,
    String? avatarUrl,
    Map<String, dynamic>? extras,
  }) async {
    var account = await qiscus.updateUser(
      name: name,
      avatarUrl: avatarUrl,
      extras: extras,
    );

    this.account = account;
    notifyListeners();

    return account;
  }

  Future<void> getUsers() async {
    var users = await qiscus.getUsers();

    this.users.addAll(users);
    notifyListeners();
  }

  Future<QChatRoom> chatUser({required String userId}) async {
    var room = await qiscus.chatUser(userId: userId);
    rooms.add(room);

    notifyListeners();

    return room;
  }

  Future<QChatRoom> getRoomWithId(int roomId) async {
    try {
      var room = rooms.firstWhere((it) => it.id == roomId);
      return room;
    } on StateError {
      var data = await qiscus.getChatRoomWithMessages(roomId: roomId);
      var rooms =
          await qiscus.getChatRooms(roomIds: [roomId], showParticipants: true);
      rooms.add(data.room);
      messages.addAll(data.messages);
      notifyListeners();

      return data.room;
    }
  }

  Future<QChatRoom> getRoomWithIdNetwork(int roomId) async {
    try {
      var data = await qiscus.getChatRoomWithMessages(roomId: roomId);
      return data.room;
    } on StateError {
      var room = rooms.firstWhere((it) => it.id == roomId);
      room.unreadCount += 1;
      return room;
    }
  }

  void cancelSubscriptions() {
    Future.wait(subs.map((it) => it.cancel()));
    subs.clear();
  }

  void resetLocalData(){
    messages = {};
    rooms = {};      // Clear all stream subscriptions
    account = null;       // Reset account to null
    users = {};           // Reset users to an empty set
    typings = {};         // Reset typings to an empty set
    presences = {};
  }

  void subscribe() {
    if (subs.isNotEmpty) return;
    subs.addAll([
      qiscus.onMessageReceived().listen(_mReceived,cancelOnError: true),
      qiscus.onMessageDelivered().listen(_mDelivered,cancelOnError: true),
      qiscus.onMessageRead().listen(_mRead,cancelOnError: true),
      qiscus.onMessageDeleted().listen(_mDeleted,cancelOnError: true),
      qiscus.onUserOnlinePresence().listen(_uPresence,cancelOnError: true),
      qiscus.onUserTyping().listen(_uTyping,cancelOnError: true),
    ]);
  }

  Future<void> clearUser() async {
    await qiscus.clearUser();
    resetLocalData();

    notifyListeners();
  }

  static QUserPresence? getPresenceForRoomId(
      BuildContext context, int chatRoomId) {
    var account = context.watch<QAccount>();
    return context.select<QiscusUtil, QUserPresence?>((it) {
      try {
        var room = it.rooms.firstWhere((v) => v.id == chatRoomId);

        if (room.type != QRoomType.single) return null;
        var other = room.participants.firstWhere((it) => it.id != account.id);

        return it.presences.firstWhere((v) {
          return v.userId == other.id;
        });
      } catch (_) {
        return null;
      }
    });
  }

  static QUserTyping? getTypingForRoomId(BuildContext context, int chatRoomId) {
    var account = context.watch<QAccount>();
    return context.select<QiscusUtil, QUserTyping?>((it) {
      try {
        var room = it.rooms.firstWhere((element) => element.id == chatRoomId);

        if (room.type != QRoomType.single) return null;
        var other = room.participants.firstWhere((it) => it.id != account.id);

        return it.typings.firstWhere((v) {
          return v.userId == other.id && v.roomId == chatRoomId;
        });
      } catch (_) {
        return null;
      }
    });
  }

  static QUserPresence? getPresenceForUser(BuildContext context, QUser user) {
    return context.select<QiscusUtil, QUserPresence?>((it) {
      try {
        return it.presences.firstWhere((v) {
          return v.userId == user.id;
        });
      } on StateError {
        return null;
      }
    });
  }

  static QUserTyping? getTypingForUser(
    BuildContext context, {
    required QUser user,
    required QChatRoom room,
  }) {
    return context.select<QiscusUtil, QUserTyping?>((it) {
      try {
        return it.typings.firstWhere((v) {
          return v.userId == user.id && v.roomId == room.id;
        });
      } on StateError {
        return null;
      }
    });
  }

  static QMessage? getLastMessageFor(
    BuildContext context, {
    required int chatRoomId,
  }) {
    return context.select<QiscusUtil, QMessage?>((it) {
      List<QMessage> messages = [];
      if(it.rooms.isEmpty) return null;
      var room = it.rooms.firstWhere((r) => r.id == chatRoomId);
      try {
        messages = it.messages.where((m) => m.chatRoomId == chatRoomId).toList()
          ..sort((m1, m2) => m2.timestamp.compareTo(m1.timestamp));
      } catch (_) {}

      try {
        return messages.first;
      } catch (_) {
        return room.lastMessage;
      }
    });
  }

  static List<QMessage> getMessagesFor(
    BuildContext context, {
    required int chatRoomId,
  }) {
    return context.select<QiscusUtil, List<QMessage>>((it) {
      return it.messages.where((m) => m.chatRoomId == chatRoomId).toList()
        ..sort((m1, m2) => m1.timestamp.compareTo(m2.timestamp));
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelSubscriptions();
  }

  void _mReceived(QMessage message) async {
    if (messages.contains(message)) {
      return;
    }

    messages.add(message);

    QChatRoom room;
    try {
      var fetchRoom = await getRoomWithIdNetwork(message.chatRoomId);
      room = rooms.firstWhere((r) => r.id == message.chatRoomId);
      room.unreadCount = fetchRoom.unreadCount;
    } catch (_) {
      room = await getRoomWithId(message.chatRoomId);
    }

    room.lastMessage = message;
    rooms.add(room);
    notifyListeners();
  }

  void _mDelivered(QMessage message) {
    logger.d('@m.delivered message($message)');
    var m = messages.firstWhere((m) => m.uniqueId == message.uniqueId);
    if (m.status != QMessageStatus.read) {
      m.status = QMessageStatus.delivered;
    }

    messages.add(m);
    notifyListeners();
  }

  void _mRead(QMessage message) {
    logger.d('@m.read message($message)');
    var m = messages.firstWhere((m) => m.uniqueId == message.uniqueId);
    m.status = QMessageStatus.read;

    messages.add(m);
    notifyListeners();
  }

  void _mDeleted(QMessage message) {
    messages.removeWhere((m) => m.uniqueId == message.uniqueId);
    notifyListeners();
  }

  void _uPresence(QUserPresence presence) {
    presences.removeWhere((element) => element.userId == presence.userId);
    presences.add(presence);
    notifyListeners();
  }

  void _uTyping(QUserTyping typing) {
    typings.add(typing);
    notifyListeners();

    Timer(const Duration(seconds: 2), () {
      typings.remove(typing);
      notifyListeners();
    });
  }

  Future<void> clearMessagesByChatRoomId({
    required List<String> roomUniqueIds,
  }) async {
    await qiscus.clearMessagesByChatRoomId(roomUniqueIds: roomUniqueIds);
    var rooms = this.rooms.where((v) => roomUniqueIds.contains(v.uniqueId));

    for (var room in rooms) {
      messages.removeWhere((m) {
        return m.chatRoomId == room.id;
      });
    }

    notifyListeners();
  }

  Future<void> deleteMessages({
    required List<String> messageUniqueIds,
  }) async {
    await qiscus.deleteMessages(messageUniqueIds: messageUniqueIds);

    messages
        .removeWhere((element) => messageUniqueIds.contains(element.uniqueId));
    notifyListeners();
  }

  Future<QMessage> sendMessage({required QMessage message}) async {
    messages.add(message);
    notifyListeners();

    var m = await qiscus.sendMessage(message: message).then((r) {
      messages.remove(message);
      messages.add(r);
      return r;
    });
    notifyListeners();

    return m;
  }

  Future<QMessage> uploadMessage({
    required QMessage message,
    required File file,
  }) async {
    message.payload?['progress'] = 0;
    messages.add(message);
    notifyListeners();

    var urlCompleter = Completer<String>();
    var stream = qiscus.upload(file);
    stream.listen((progress) {
      var url = progress.data;
      logger.d('@upload: progress(${progress.progress}), url($url)');

      message.payload?['progress'] = progress.progress;
      messages.add(message);
      notifyListeners();

      if (url != null) {
        urlCompleter.complete(url);
      }
    }, onError: (error) {
      urlCompleter.completeError(error);
    });
    var url = await urlCompleter.future;

    message.payload?['url'] = url;
    messages.add(message);
    notifyListeners();

    var m = await qiscus.sendMessage(message: message);
    messages.remove(message);
    messages.add(m);
    notifyListeners();

    return m;
  }

  Future<void> addParticipants({
    required int roomId,
    required List<String> userIds,
  }) async {
    QChatRoom room;
    try {
      room = rooms.firstWhere((r) => r.id == roomId);
    } on StateError {
      room = await getRoomWithId(roomId);
    }

    var users = this.users.where((u) => userIds.contains(u.id));
    var participants = users.map((u) => QParticipant(
          id: u.id,
          name: u.name,
          avatarUrl: u.avatarUrl,
          extras: u.extras,
        ));
    room.participants.addAll(participants);
    rooms.removeWhere((r) => r.uniqueId == room.uniqueId);
    rooms.add(room);
    notifyListeners();
  }

  Future<void> updateChatRoom({
    required int roomId,
    String? name,
    String? avatarUrl,
    Map<String, Object?>? extras,
  }) async {
    var room = await qiscus.updateChatRoom(
      roomId: roomId,
      avatarUrl: avatarUrl,
      extras: extras,
      name: name,
    );

    rooms.removeWhere((r) => r.id == roomId);
    rooms.add(room);
    notifyListeners();
  }

  Future<void> removeParticipants({
    required int roomId,
    required List<String> userIds,
  }) async {
    await qiscus.removeParticipants(roomId: roomId, userIds: userIds);
    var room = rooms.firstWhere((r) => r.id == roomId);
    room.participants.removeWhere((u) => userIds.contains(u.id));
    rooms.add(room);
    notifyListeners();
  }

  Future<QChatRoom> createGroupChat({
    required String name,
    required List<String> userIds,
    String? avatarUrl,
    Map<String, Object?>? extras,
  }) async {
    var room = await qiscus.createGroupChat(
      name: name,
      userIds: userIds,
      avatarUrl: avatarUrl,
      extras: extras,
    );

    rooms.add(room);
    notifyListeners();

    return room;
  }

  @override
  void reassemble() {
    logger.d('re-assemble this things');
  }

  void subscribePresence(QChatRoom room) {
    if (room.type != QRoomType.single && room.participants.isEmpty) return;

    try {
      var userId = room.participants.firstWhere((u) => u.id != account?.id);
      qiscus.subscribeUserOnlinePresence(userId.id);
    } catch (er) {
      logger.e('Could not subscribe user presence for room(${room.id})', er);
    }
  }
}
