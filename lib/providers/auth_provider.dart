import 'package:flutter/foundation.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';
import 'package:qiscus_chat_flutter_sample/services/qiscus_service.dart';
import 'package:qiscus_chat_flutter_sample/services/push_service.dart';

class AuthProvider with ChangeNotifier {
  AuthProvider({
    QiscusGateway? qiscusService,
    PushService? pushService,
  })  : _qiscusService = qiscusService ?? QiscusService.instance,
        _pushService = pushService ?? PushService() {
    initialized = _checkLoginStatus();
  }

  final QiscusGateway _qiscusService;
  final PushService _pushService;

  QAccount? _currentUser;
  bool _isLoading = true;
  bool _isInitialized = false;
  String? _error;
  late final Future<void> initialized;

  QAccount? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  /// Check if user is already logged in
  Future<void> _checkLoginStatus() async {
    try {
      if (_qiscusService.isLoggedIn()) {
        _currentUser = _qiscusService.getCurrentUser();
        if (_pushService.isAvailable) {
          await _pushService.registerForUser(_qiscusService.sdk);
        }
      }
    } catch (e, stackTrace) {
      _error = 'Unable to restore the Qiscus session';
      debugPrint('Session restoration failed: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login with credentials
  Future<bool> login({
    required String userId,
    required String userKey,
    String? username,
    String? avatarUrl,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      debugPrint('Attempting login for: $userId');

      final account = await _qiscusService.loginWithCredentials(
        userId: userId,
        userKey: userKey,
        username: username,
        avatarUrl: avatarUrl,
      );

      _currentUser = account;
      if (_pushService.isAvailable) {
        await _pushService.registerForUser(_qiscusService.sdk);
      }
      _setLoading(false);
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ Login failed: $e');
      debugPrint('Stack trace: $stackTrace');
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// Login with JWT token
  Future<bool> loginWithToken({required String token}) async {
    _setLoading(true);
    _error = null;

    try {
      final account = await _qiscusService.loginWithToken(token: token);
      _currentUser = account;
      if (_pushService.isAvailable) {
        await _pushService.registerForUser(_qiscusService.sdk);
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _pushService.unregisterCurrentToken();
      await _qiscusService.logout();
      _currentUser = null;
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  /// Update profile
  Future<bool> updateProfile({
    String? username,
    String? avatarUrl,
    Map<String, dynamic>? extras,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final account = await _qiscusService.updateProfile(
        username: username,
        avatarUrl: avatarUrl,
        extras: extras,
      );

      _currentUser = account;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
