import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:qiscus_chat_flutter_sample/providers/chat_provider.dart';
import 'package:qiscus_chat_flutter_sample/services/qiscus_service.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

void main() {
  late FakeQiscusGateway gateway;
  late ChatProvider provider;

  setUp(() {
    gateway = FakeQiscusGateway();
    provider = ChatProvider(qiscusService: gateway);
  });

  tearDown(() {
    provider.dispose();
    gateway.dispose();
  });

  test('entering a room commits its unread count after markAsRead', () async {
    final room = testRoom(unreadCount: 2);
    final message = testMessage(id: 10, roomId: room.id);
    gateway
      ..rooms = [room]
      ..totalUnread = 2
      ..roomData = QChatRoomWithMessages(room, [message]);

    await provider.loadChatRooms();
    await provider.enterChatRoom(room);

    expect(gateway.lastReadMessageId, message.id);
    expect(provider.chatRooms.single.unreadCount, 0);
    expect(provider.unreadCount, 0);
  });

  test('message in an inactive room increments room and total unread',
      () async {
    final room = testRoom();
    gateway
      ..rooms = [room]
      ..totalUnread = 0;
    await provider.loadChatRooms();

    gateway.messageReceived.add(testMessage(id: 11, roomId: room.id));
    await Future<void>.delayed(Duration.zero);

    expect(provider.chatRooms.single.unreadCount, 1);
    expect(provider.unreadCount, 1);
  });

  test('message in active room is read without incrementing unread', () async {
    final room = testRoom();
    gateway
      ..rooms = [room]
      ..totalUnread = 0
      ..roomData = QChatRoomWithMessages(room, []);
    await provider.loadChatRooms();
    await provider.enterChatRoom(room);

    gateway.messageReceived.add(testMessage(id: 12, roomId: room.id));
    await Future<void>.delayed(const Duration(milliseconds: 550));

    expect(provider.chatRooms.single.unreadCount, 0);
    expect(provider.unreadCount, 0);
    expect(gateway.lastReadMessageId, 12);
  });

  test('typing publishes once and clears after idle timeout', () async {
    final room = testRoom();
    gateway
      ..rooms = [room]
      ..roomData = QChatRoomWithMessages(room, []);
    await provider.enterChatRoom(room);

    provider
      ..handleTypingInput('h')
      ..handleTypingInput('he')
      ..handleTypingInput('hello');
    await Future<void>.delayed(Duration.zero);
    expect(gateway.typingStates, [true]);

    await Future<void>.delayed(const Duration(milliseconds: 1550));
    expect(gateway.typingStates, [true, false]);
  });

  test('messageUpdated event replaces the active message', () async {
    final room = testRoom();
    final original = testMessage(id: 20, roomId: room.id);
    gateway
      ..rooms = [room]
      ..roomData = QChatRoomWithMessages(room, [original]);
    await provider.enterChatRoom(room);

    final updated = testMessage(id: 20, roomId: room.id)..text = 'Edited';
    gateway.messageUpdated.add(updated);
    await Future<void>.delayed(Duration.zero);

    expect(provider.messages.single.text, 'Edited');
  });
}

QChatRoom testRoom({int unreadCount = 0}) => QChatRoom(
      id: 1,
      uniqueId: 'room-1',
      name: 'Room',
      unreadCount: unreadCount,
    );

QMessage testMessage({required int id, required int roomId}) => QMessage(
      id: id,
      chatRoomId: roomId,
      previousMessageId: id - 1,
      uniqueId: 'message-$id',
      text: 'Message $id',
      status: QMessageStatus.sent,
      type: QMessageType.text,
      extras: null,
      payload: null,
      sender: const QUser(id: 'other', name: 'Other'),
      timestamp: DateTime(2026, 1, 1).add(Duration(seconds: id)),
    );

class FakeQiscusGateway implements QiscusGateway {
  final messageReceived = StreamController<QMessage>.broadcast();
  final messageDelivered = StreamController<QMessage>.broadcast();
  final messageRead = StreamController<QMessage>.broadcast();
  final messageDeleted = StreamController<QMessage>.broadcast();
  final messageUpdated = StreamController<QMessage>.broadcast();
  final roomCleared = StreamController<int>.broadcast();
  final typing = StreamController<QUserTyping>.broadcast();
  final presence = StreamController<QUserPresence>.broadcast();
  final connected = StreamController<void>.broadcast();
  final reconnecting = StreamController<void>.broadcast();
  final disconnected = StreamController<void>.broadcast();
  final realtimeError = StreamController<QError>.broadcast();

  List<QChatRoom> rooms = [];
  int totalUnread = 0;
  QChatRoomWithMessages? roomData;
  int? lastReadMessageId;
  final List<bool> typingStates = [];

  @override
  QiscusSDK get sdk => QiscusSDK.instance;
  @override
  Stream<QMessage> get onMessageReceived => messageReceived.stream;
  @override
  Stream<QMessage> get onMessageDelivered => messageDelivered.stream;
  @override
  Stream<QMessage> get onMessageRead => messageRead.stream;
  @override
  Stream<QMessage> get onMessageDeleted => messageDeleted.stream;
  @override
  Stream<QMessage> get onMessageUpdated => messageUpdated.stream;
  @override
  Stream<int> get onChatRoomCleared => roomCleared.stream;
  @override
  Stream<QUserTyping> get onUserTyping => typing.stream;
  @override
  Stream<QUserPresence> get onUserPresence => presence.stream;
  @override
  Stream<void> get onConnected => connected.stream;
  @override
  Stream<void> get onReconnecting => reconnecting.stream;
  @override
  Stream<void> get onDisconnected => disconnected.stream;
  @override
  Stream<QError> get onRealtimeError => realtimeError.stream;

  @override
  Future<List<QChatRoom>> getAllChatRooms({
    bool? showParticipant,
    bool? showRemoved,
    bool? showEmpty,
    int? limit,
    int? page,
  }) async =>
      rooms;

  @override
  Future<int> getTotalUnreadCount() async => totalUnread;

  @override
  QAccount? getCurrentUser() => null;

  @override
  Future<QChatRoomWithMessages> getChatRoomWithMessages({
    required int roomId,
  }) async =>
      roomData ?? QChatRoomWithMessages(rooms.single, const []);

  @override
  Future<void> markAsRead({
    required int roomId,
    required int messageId,
  }) async {
    lastReadMessageId = messageId;
  }

  @override
  Future<void> publishTyping({
    required int roomId,
    bool isTyping = true,
  }) async {
    typingStates.add(isTyping);
  }

  @override
  void subscribeChatRoom(QChatRoom room) {}
  @override
  void unsubscribeChatRoom(QChatRoom room) {}
  @override
  void subscribeUserOnlinePresence(String userId) {}
  @override
  void unsubscribeUserOnlinePresence(String userId) {}

  void dispose() {
    messageReceived.close();
    messageDelivered.close();
    messageRead.close();
    messageDeleted.close();
    messageUpdated.close();
    roomCleared.close();
    typing.close();
    presence.close();
    connected.close();
    reconnecting.close();
    disconnected.close();
    realtimeError.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
