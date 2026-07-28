import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:qiscus_chat_flutter_sample/services/qiscus_service.dart';

class FeatureGalleryProvider with ChangeNotifier {
  FeatureGalleryProvider({QiscusService? qiscusService})
      : _service = qiscusService ?? QiscusService.instance;

  final QiscusService _service;
  bool _isLoading = false;
  String? _result;
  String? _error;
  StreamSubscription<Map<String, Object?>>? _customEventSubscription;
  int? _customEventRoomId;

  bool get isLoading => _isLoading;
  String? get result => _result;
  String? get error => _error;

  Future<void> getJwtNonce() =>
      _run(() async => 'JWT nonce:\n${await _service.sdk.getJWTNonce()}');

  Future<void> blockUser(String userId) => _run(() async {
        final user = await _service.sdk.blockUser(userId: userId);
        return 'Blocked ${user.id}';
      });

  Future<void> unblockUser(String userId) => _run(() async {
        final user = await _service.sdk.unblockUser(userId: userId);
        return 'Unblocked ${user.id}';
      });

  Future<void> listBlockedUsers() => _run(() async {
        final users = await _service.sdk.getBlockedUsers(limit: 50);
        return users.isEmpty
            ? 'No blocked users'
            : users.map((user) => '${user.name} (${user.id})').join('\n');
      });

  Future<void> updateRoom({
    required int roomId,
    required String name,
  }) =>
      _run(() async {
        final room = await _service.sdk.updateChatRoom(
          roomId: roomId,
          name: name,
        );
        return 'Room ${room.id} renamed to ${room.name}';
      });

  Future<void> sendCustomMessage({
    required int roomId,
    required String type,
    required String text,
  }) =>
      _run(() async {
        final message = _service.sdk.generateCustomMessage(
          chatRoomId: roomId,
          text: text,
          type: type,
          payload: {'text': text, 'source': 'feature_gallery'},
        );
        final sent = await _service.sdk.sendMessage(message: message);
        return 'Custom message sent: ${sent.id}';
      });

  Future<void> publishCustomEvent({
    required int roomId,
    required String value,
  }) =>
      _run(() async {
        await _service.sdk.publishCustomEvent(
          roomId: roomId,
          payload: {'event': value},
        );
        return 'Custom event published to room $roomId';
      });

  Future<void> subscribeCustomEvents(int roomId) => _run(() async {
        await _customEventSubscription?.cancel();
        if (_customEventRoomId != null) {
          _service.sdk.unsubscribeCustomEvent(roomId: _customEventRoomId!);
        }
        _customEventRoomId = roomId;
        _customEventSubscription =
            _service.sdk.subscribeCustomEvent(roomId: roomId).listen((payload) {
          _result = 'Custom event received:\n$payload';
          notifyListeners();
        });
        return 'Listening for custom events in room $roomId';
      });

  Future<void> listFiles(int roomId) => _run(() async {
        final files = await _service.sdk.getFileList(
          roomIds: [roomId],
          limit: 50,
        );
        return files.isEmpty
            ? 'No files found'
            : files.map((file) => '${file.text} (${file.id})').join('\n');
      });

  Future<void> synchronize() => _run(() async {
        _service.sdk.synchronize();
        _service.sdk.synchronizeEvent();
        return 'Message and event synchronization requested';
      });

  Future<void> setRealtimeConnection({required bool open}) => _run(() async {
        final changed = open
            ? await _service.sdk.openRealtimeConnection()
            : await _service.sdk.closeRealtimeConnection();
        return 'Realtime ${open ? 'open' : 'closed'}: $changed';
      });

  String thumbnailUrl(String url) => _service.sdk.getThumbnailURL(url);

  Future<void> _run(Future<String> Function() action) async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    _result = null;
    notifyListeners();
    try {
      _result = await action();
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _customEventSubscription?.cancel();
    if (_customEventRoomId != null) {
      _service.sdk.unsubscribeCustomEvent(roomId: _customEventRoomId!);
    }
    super.dispose();
  }
}
