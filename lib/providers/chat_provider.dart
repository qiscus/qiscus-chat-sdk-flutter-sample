import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';
import 'package:qiscus_chat_flutter_sample/services/qiscus_service.dart';

class ChatProvider with ChangeNotifier {
  ChatProvider({QiscusGateway? qiscusService})
      : _qiscusService = qiscusService ?? QiscusService.instance {
    _setupEventListeners();
  }

  final QiscusGateway _qiscusService;

  List<QChatRoom> _chatRooms = [];
  QChatRoom? _currentRoom;
  List<QMessage> _messages = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreMessages = true;
  bool _hasMoreRooms = true;
  int _roomPage = 1;
  String? _error;
  Map<String, bool> _typingUsers = {};
  final Map<String, bool> _onlineUsers = {};
  int _unreadCount = 0;
  String _connectionState = 'connecting';
  String? _realtimeError;
  // Track upload progress for each message (uniqueId -> progress percentage)
  final Map<String, int> _uploadProgress = {};

  List<QChatRoom> get chatRooms => List.unmodifiable(_chatRooms);
  QChatRoom? get currentRoom => _currentRoom;
  List<QMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreMessages => _hasMoreMessages;
  bool get hasMoreRooms => _hasMoreRooms;
  String? get error => _error;
  String get connectionState => _connectionState;
  String? get realtimeError => _realtimeError;
  Map<String, bool> get typingUsers => Map.unmodifiable(_typingUsers);
  Map<String, bool> get onlineUsers => Map.unmodifiable(_onlineUsers);
  int get unreadCount => _unreadCount;
  Map<String, int> get uploadProgress => Map.unmodifiable(_uploadProgress);

  /// Get upload progress for a specific message
  int getUploadProgress(String messageUniqueId) {
    return _uploadProgress[messageUniqueId] ?? 0;
  }

  StreamSubscription? _messageReceivedSub;
  StreamSubscription? _messageDeliveredSub;
  StreamSubscription? _messageReadSub;
  StreamSubscription? _messageDeletedSub;
  StreamSubscription? _userTypingSub;
  StreamSubscription? _userPresenceSub;
  StreamSubscription? _connectedSub;
  StreamSubscription? _reconnectingSub;
  StreamSubscription? _disconnectedSub;
  StreamSubscription? _realtimeErrorSub;
  StreamSubscription? _messageUpdatedSub;
  StreamSubscription? _chatRoomClearedSub;
  Timer? _markAsReadDebounce;
  Timer? _typingIdleTimer;
  bool _typingPublished = false;
  final Set<String> _presenceSubscriptions = {};
  final Set<StreamSubscription<dynamic>> _uploadSubscriptions = {};
  int? _pendingReadRoomId;
  int? _pendingReadMessageId;
  int _roomSession = 0;
  int _unreadRevision = 0;
  bool _disposed = false;

  /// Debounce markAsRead so a burst of incoming messages results in a
  /// single `update_comment_status` request for the latest message,
  /// instead of one request per message (which can trigger 429s).
  void _scheduleMarkAsRead({required int roomId, required int messageId}) {
    final wasPending = _markAsReadDebounce?.isActive ?? false;
    _markAsReadDebounce?.cancel();
    _pendingReadRoomId = roomId;
    _pendingReadMessageId = messageId;
    if (wasPending) {
      debugPrint(
          '⏱️ markAsRead debounce reset (burst) — room=$roomId latest messageId=$messageId');
    }
    _markAsReadDebounce = Timer(const Duration(milliseconds: 500), () {
      unawaited(_flushPendingMarkAsRead(roomId: roomId));
    });
  }

  /// Flush the newest pending read receipt for [roomId].
  ///
  /// A failed receipt is retained when there is no newer pending receipt, so
  /// it can be retried when the room is left or the connection is restored.
  Future<void> _flushPendingMarkAsRead({int? roomId}) async {
    final pendingRoomId = _pendingReadRoomId;
    final pendingMessageId = _pendingReadMessageId;
    if (pendingRoomId == null ||
        pendingMessageId == null ||
        (roomId != null && pendingRoomId != roomId)) {
      return;
    }

    _markAsReadDebounce?.cancel();
    _markAsReadDebounce = null;
    _pendingReadRoomId = null;
    _pendingReadMessageId = null;

    debugPrint(
        '✅ markAsRead flushing — room=$pendingRoomId messageId=$pendingMessageId');
    final succeeded = await _markRoomAsRead(
      roomId: pendingRoomId,
      messageId: pendingMessageId,
    );

    if (!succeeded && _pendingReadRoomId == null) {
      _pendingReadRoomId = pendingRoomId;
      _pendingReadMessageId = pendingMessageId;
    }
  }

  Future<bool> _markRoomAsRead({
    required int roomId,
    required int messageId,
  }) async {
    try {
      await _qiscusService.markAsRead(
        roomId: roomId,
        messageId: messageId,
      );
      _commitRoomRead(roomId);
      return true;
    } catch (e) {
      debugPrint(
          '❌ Failed to mark room $roomId as read at message $messageId: $e');
      return false;
    }
  }

  /// Commit per-room and aggregate unread state together after the server has
  /// accepted the read receipt.
  void _commitRoomRead(int roomId) {
    final roomIndex = _chatRooms.indexWhere((room) => room.id == roomId);
    if (roomIndex == -1) {
      // The room may be outside the loaded page. Reconcile the aggregate from
      // the server because there is no local per-room value to subtract.
      unawaited(_updateUnreadCount());
      return;
    }

    final previousUnread = _chatRooms[roomIndex].unreadCount;
    if (previousUnread == 0) return;

    _chatRooms[roomIndex].unreadCount = 0;
    final nextTotal = _unreadCount - previousUnread;
    _unreadCount = nextTotal < 0 ? 0 : nextTotal;
    _unreadRevision++;
    notifyListeners();
  }

  /// Setup real-time event listeners
  void _setupEventListeners() {
    // Listen to new messages
    _messageReceivedSub = _qiscusService.onMessageReceived.listen((message) {
      final isCurrentRoom =
          _currentRoom != null && message.chatRoomId == _currentRoom!.id;
      final roomIndex =
          _chatRooms.indexWhere((room) => room.id == message.chatRoomId);

      if (roomIndex >= 0) {
        final room = _chatRooms[roomIndex];
        if (room.lastMessage == null ||
            room.lastMessage!.timestamp.isBefore(message.timestamp)) {
          room.lastMessage = message;
        }
        if (!isCurrentRoom) {
          room.unreadCount += 1;
        }
      }

      if (isCurrentRoom) {
        _addMessage(message);
        _scheduleMarkAsRead(roomId: message.chatRoomId, messageId: message.id);
      } else {
        // The aggregate can include rooms outside the currently loaded page,
        // so increment it even if this room is not present in _chatRooms.
        _unreadCount += 1;
        _unreadRevision++;
        notifyListeners();
      }
    });

    // Listen to message delivered
    _messageDeliveredSub = _qiscusService.onMessageDelivered.listen((message) {
      _updateMessageStatus(message);
    });

    // Listen to message read
    _messageReadSub = _qiscusService.onMessageRead.listen((message) {
      _updateMessageStatus(message);
    });

    // Listen to deleted messages
    _messageDeletedSub = _qiscusService.onMessageDeleted.listen((message) {
      _removeMessage(message);
    });
    _messageUpdatedSub = _qiscusService.onMessageUpdated.listen((message) {
      _replaceMessage(message);
    });
    _chatRoomClearedSub = _qiscusService.onChatRoomCleared.listen((roomId) {
      if (_currentRoom?.id == roomId) {
        _messages = [];
        notifyListeners();
      }
    });

    // Listen to typing indicator
    _userTypingSub = _qiscusService.onUserTyping.listen((typing) {
      if (_currentRoom != null && typing.roomId == _currentRoom!.id) {
        _typingUsers[typing.userId] = typing.isTyping;
        notifyListeners();
      }
    });

    // Listen to user presence
    _userPresenceSub = _qiscusService.onUserPresence.listen((presence) {
      _onlineUsers[presence.userId] = presence.isOnline;
      notifyListeners();
    });

    // Re-subscribe to the active room on reconnect to close the window
    // where room-scoped MQTT events could be missed during the drop.
    _connectedSub = _qiscusService.onConnected.listen((_) {
      _connectionState = 'connected';
      _realtimeError = null;
      debugPrint(
          '🟢 [${DateTime.now().toIso8601String()}] ChatProvider: onConnected, currentRoom=${_currentRoom?.id}');
      if (_currentRoom != null) {
        debugPrint('🔁 Resubscribing room ${_currentRoom!.id} after connect');
        _qiscusService.subscribeChatRoom(_currentRoom!);
      }
      unawaited(_flushPendingMarkAsRead());
      unawaited(_updateUnreadCount());
      notifyListeners();
    });
    _reconnectingSub = _qiscusService.onReconnecting.listen((_) {
      _connectionState = 'reconnecting';
      debugPrint(
          '🟡 [${DateTime.now().toIso8601String()}] ChatProvider: onReconnecting, currentRoom=${_currentRoom?.id}');
      if (_currentRoom != null) {
        debugPrint(
            '🔁 Resubscribing room ${_currentRoom!.id} after reconnecting event');
        _qiscusService.subscribeChatRoom(_currentRoom!);
      }
      notifyListeners();
    });
    _disconnectedSub = _qiscusService.onDisconnected.listen((_) {
      _connectionState = 'disconnected';
      notifyListeners();
    });
    _realtimeErrorSub = _qiscusService.onRealtimeError.listen((error) {
      _realtimeError = error.message;
      notifyListeners();
    });
  }

  /// Load all chat rooms
  Future<void> loadChatRooms({
    bool? showParticipant = true,
    int? limit = 20,
    int? page,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final rooms = await _qiscusService.getAllChatRooms(
        showParticipant: showParticipant,
        limit: limit,
        page: page,
      );

      _chatRooms = rooms;
      _roomPage = page ?? 1;
      _hasMoreRooms = rooms.length == (limit ?? 20);
      _unreadRevision++;
      _setLoading(false);
      await _updateUnreadCount();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> loadMoreChatRooms({int limit = 20}) async {
    if (_isLoadingMore || !_hasMoreRooms) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final nextPage = _roomPage + 1;
      final rooms = await _qiscusService.getAllChatRooms(
        showParticipant: true,
        limit: limit,
        page: nextPage,
      );
      final knownIds = _chatRooms.map((room) => room.id).toSet();
      _chatRooms.addAll(rooms.where((room) => knownIds.add(room.id)));
      _roomPage = nextPage;
      _hasMoreRooms = rooms.length == limit;
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Create 1-on-1 chat
  Future<QChatRoom?> createChat({
    required String userId,
    Map<String, dynamic>? extras,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final room = await _qiscusService.createChatRoom(
        userId: userId,
        extras: extras,
      );
      _upsertRoom(room);
      _setLoading(false);
      return room;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return null;
    }
  }

  /// Create group chat
  Future<QChatRoom?> createGroupChat({
    required String name,
    required List<String> userIds,
    String? avatarUrl,
    Map<String, dynamic>? extras,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final room = await _qiscusService.createGroupChat(
        name: name,
        userIds: userIds,
        avatarUrl: avatarUrl,
        extras: extras,
      );
      _upsertRoom(room);
      _setLoading(false);
      return room;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return null;
    }
  }

  /// Create or get channel
  Future<QChatRoom?> createChannel({
    required String uniqueId,
    String? name,
    String? avatarUrl,
    Map<String, dynamic>? extras,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final room = await _qiscusService.createChannel(
        uniqueId: uniqueId,
        name: name,
        avatarUrl: avatarUrl,
        extras: extras,
      );
      _upsertRoom(room);
      _setLoading(false);
      return room;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return null;
    }
  }

  /// Enter chat room
  Future<void> enterChatRoom(QChatRoom room) async {
    final session = ++_roomSession;
    _isLoadingMore = false;
    _hasMoreMessages = true;
    _setLoading(true);
    _error = null;
    _currentRoom = room;

    try {
      // Subscribe to room for real-time updates
      _qiscusService.subscribeChatRoom(room);

      // Load messages
      final data =
          await _qiscusService.getChatRoomWithMessages(roomId: room.id);

      if (session != _roomSession || _currentRoom?.id != room.id) {
        return;
      }

      _messages = data.messages.toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      _hasMoreMessages = data.messages.length >= 20;
      _subscribeToParticipantPresence(data.room.participants);
      notifyListeners();

      // Mark last message as read
      if (_messages.isNotEmpty) {
        await _markRoomAsRead(
          roomId: room.id,
          messageId: _messages.last.id,
        );
      }

      if (session == _roomSession && _currentRoom?.id == room.id) {
        _setLoading(false);
      }
    } catch (e) {
      if (session == _roomSession && _currentRoom?.id == room.id) {
        _error = e.toString();
        _setLoading(false);
      }
    }
  }

  /// Leave chat room
  Future<void> leaveChatRoom() async {
    final room = _currentRoom;
    if (room == null) return;

    _roomSession++;
    _typingIdleTimer?.cancel();
    if (_typingPublished) {
      unawaited(
        _qiscusService.publishTyping(roomId: room.id, isTyping: false),
      );
    }
    _typingPublished = false;
    for (final userId in _presenceSubscriptions) {
      _qiscusService.unsubscribeUserOnlinePresence(userId);
    }
    _presenceSubscriptions.clear();
    _qiscusService.unsubscribeChatRoom(room);
    _currentRoom = null;
    _messages = [];
    _typingUsers = {};
    _isLoading = false;
    _isLoadingMore = false;
    // dispose() runs while Flutter is finalizing (and locking) the widget tree.
    // Defer provider notification until that lifecycle phase has completed.
    Future.microtask(() {
      if (!_disposed) notifyListeners();
    });

    await _flushPendingMarkAsRead(roomId: room.id);
  }

  void _subscribeToParticipantPresence(List<QParticipant> participants) {
    final currentUserId = _qiscusService.getCurrentUser()?.id;
    for (final participant in participants) {
      if (participant.id == currentUserId ||
          !_presenceSubscriptions.add(participant.id)) {
        continue;
      }
      _qiscusService.subscribeUserOnlinePresence(participant.id);
    }
  }

  /// Send text message
  Future<void> sendMessage(String text) async {
    if (_currentRoom == null || text.trim().isEmpty) return;

    final pendingMessage = _qiscusService.sdk.generateMessage(
      chatRoomId: _currentRoom!.id,
      text: text,
    );
    _addMessage(pendingMessage);

    try {
      final sentMessage = await _qiscusService.sendMessage(
        chatRoomId: _currentRoom!.id,
        text: text,
      );
      _updateMessageInList(pendingMessage, sentMessage);
    } catch (e) {
      _removeMessage(pendingMessage);
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Send file message with placeholder (like JavaScript flow)
  Future<void> sendFileMessageWithPlaceholder(File file,
      {String? caption}) async {
    final room = _currentRoom;
    if (room == null) return;
    final session = _roomSession;

    try {
      // Get file extension
      final fileName = file.path.split('/').last;
      final extension = fileName.split('.').last.toUpperCase();

      // Prepare placeholder message
      final placeholderText = caption ?? 'File attachment .$extension';
      final placeholderMessage = _qiscusService.sdk.generateMessage(
        chatRoomId: room.id,
        text: placeholderText,
      );

      // Add placeholder message to UI immediately
      _addMessage(placeholderMessage);

      // Upload file and track progress
      late final StreamSubscription<dynamic> subscription;
      subscription = _qiscusService
          .sendFileMessage(
        chatRoomId: room.id,
        file: file,
        caption: placeholderText,
      )
          .listen(
        (progress) {
          if (session != _roomSession || _currentRoom?.id != room.id) return;
          if (progress.data != null) {
            // File uploaded successfully, update the placeholder message
            final uploadedMessage = progress.data!;
            _updateMessageInList(placeholderMessage, uploadedMessage);
            // Remove from upload progress tracking
            _uploadProgress.remove(placeholderMessage.uniqueId);
            notifyListeners();
            debugPrint('✅ File uploaded: ${uploadedMessage.text}');
          } else {
            // Update upload progress
            _uploadProgress[placeholderMessage.uniqueId] =
                progress.progress.toInt();
            notifyListeners();
            debugPrint('📤 Upload progress: ${progress.progress}%');
          }
        },
        onError: (error) {
          _uploadSubscriptions.remove(subscription);
          if (session != _roomSession || _currentRoom?.id != room.id) return;
          // Remove placeholder message on error
          _removeMessage(placeholderMessage);
          _uploadProgress.remove(placeholderMessage.uniqueId);
          _error = 'Failed to upload file: $error';
          notifyListeners();
          debugPrint('❌ Upload failed: $error');
        },
        onDone: () => _uploadSubscriptions.remove(subscription),
      );
      _uploadSubscriptions.add(subscription);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('❌ Error: $e');
    }
  }

  /// Update message
  Future<void> updateMessage(QMessage message, String newText) async {
    try {
      final updated = await _qiscusService.updateMessage(
        message: message,
        newText: newText,
      );
      _replaceMessage(updated);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Delete messages
  Future<void> deleteMessages(List<String> messageUniqueIds) async {
    try {
      await _qiscusService.deleteMessages(messageUniqueIds: messageUniqueIds);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Load previous messages
  Future<void> loadPreviousMessages() async {
    final room = _currentRoom;
    if (room == null ||
        _messages.isEmpty ||
        _isLoadingMore ||
        !_hasMoreMessages) {
      return;
    }
    final session = _roomSession;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final oldMessages = await _qiscusService.loadPreviousMessages(
        roomId: room.id,
        messageId: _messages.first.id,
        limit: 20,
      );

      if (session != _roomSession || _currentRoom?.id != room.id) return;
      final knownIds = _messages.map((message) => message.uniqueId).toSet();
      _messages.addAll(
        oldMessages.where((message) => knownIds.add(message.uniqueId)),
      );
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      _hasMoreMessages = oldMessages.length >= 20;
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      if (session != _roomSession || _currentRoom?.id != room.id) return;
      _error = e.toString();
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Publish typing indicator
  Future<void> publishTyping(bool isTyping) async {
    if (_currentRoom == null) return;

    try {
      await _qiscusService.publishTyping(
        roomId: _currentRoom!.id,
        isTyping: isTyping,
      );
    } catch (e) {
      debugPrint('Error publishing typing: $e');
    }
  }

  void handleTypingInput(String text) {
    final hasText = text.trim().isNotEmpty;
    _typingIdleTimer?.cancel();

    if (!hasText) {
      if (_typingPublished) unawaited(publishTyping(false));
      _typingPublished = false;
      return;
    }

    if (!_typingPublished) {
      _typingPublished = true;
      unawaited(publishTyping(true));
    }
    _typingIdleTimer = Timer(const Duration(milliseconds: 1500), () {
      if (_typingPublished) unawaited(publishTyping(false));
      _typingPublished = false;
    });
  }

  /// Add participants to group
  Future<bool> addParticipants(List<String> userIds) async {
    if (_currentRoom == null) return false;

    try {
      await _qiscusService.addParticipants(
        roomId: _currentRoom!.id,
        userIds: userIds,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Remove participants from group
  Future<bool> removeParticipants(List<String> userIds) async {
    if (_currentRoom == null) return false;

    try {
      await _qiscusService.removeParticipants(
        roomId: _currentRoom!.id,
        userIds: userIds,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Get participants
  Future<List<QParticipant>> getParticipants() async {
    if (_currentRoom == null) return [];

    try {
      return await _qiscusService.getParticipants(
        roomUniqueId: _currentRoom!.uniqueId,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Clear messages in room
  Future<void> clearMessages() async {
    if (_currentRoom == null) return;

    try {
      await _qiscusService.clearMessages(
        roomUniqueIds: [_currentRoom!.uniqueId],
      );
      _messages = [];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Update unread count
  Future<void> _updateUnreadCount() async {
    final revision = _unreadRevision;
    try {
      final count = await _qiscusService.getTotalUnreadCount();
      if (revision != _unreadRevision) {
        debugPrint('Skipping stale total unread response');
        return;
      }
      _unreadCount = count;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating unread count: $e');
    }
  }

  /// Add message to list
  void _upsertRoom(QChatRoom room) {
    final index = _chatRooms.indexWhere((item) => item.id == room.id);
    if (index == -1) {
      _chatRooms.insert(0, room);
    } else {
      _chatRooms[index] = room;
    }
  }

  void _addMessage(QMessage message) {
    final index = _messages.indexWhere((m) => m.uniqueId == message.uniqueId);
    if (index == -1) {
      _messages.add(message);
      notifyListeners();
    }
  }

  /// Update message status
  void _updateMessageStatus(QMessage message) {
    final index = _messages.indexWhere((m) => m.id == message.id);
    if (index != -1) {
      _messages[index] = message;
      notifyListeners();
    }
  }

  void _replaceMessage(QMessage message) {
    final index = _messages.indexWhere(
      (item) => item.id == message.id || item.uniqueId == message.uniqueId,
    );
    if (index == -1) return;
    _messages[index] = message;
    notifyListeners();
  }

  /// Update message in list (for replacing placeholder with actual message)
  void _updateMessageInList(QMessage oldMessage, QMessage newMessage) {
    final index =
        _messages.indexWhere((m) => m.uniqueId == oldMessage.uniqueId);
    if (index != -1) {
      _messages[index] = newMessage;
      notifyListeners();
    } else {
      // If not found by uniqueId, try to find by text and add new message
      _addMessage(newMessage);
    }
  }

  /// Remove message from list
  void _removeMessage(QMessage message) {
    _messages.removeWhere((m) => m.id == message.id);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _messageReceivedSub?.cancel();
    _messageDeliveredSub?.cancel();
    _messageReadSub?.cancel();
    _messageDeletedSub?.cancel();
    _userTypingSub?.cancel();
    _userPresenceSub?.cancel();
    _connectedSub?.cancel();
    _reconnectingSub?.cancel();
    _disconnectedSub?.cancel();
    _realtimeErrorSub?.cancel();
    _messageUpdatedSub?.cancel();
    _chatRoomClearedSub?.cancel();
    _markAsReadDebounce?.cancel();
    _typingIdleTimer?.cancel();
    for (final subscription in _uploadSubscriptions) {
      unawaited(subscription.cancel());
    }
    for (final userId in _presenceSubscriptions) {
      _qiscusService.unsubscribeUserOnlinePresence(userId);
    }
    _uploadSubscriptions.clear();
    _presenceSubscriptions.clear();
    _pendingReadRoomId = null;
    _pendingReadMessageId = null;
    super.dispose();
  }
}
