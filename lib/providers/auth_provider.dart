import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../utils/pkce_utils.dart';
import '../utils/constants.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

enum OAuthStatus {
  idle,
  creatingSession,
  waitingForAuth,
  polling,
  exchangingToken,
  success,
  error,
  timeout,
  cancelled,
}

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;

  // Expose API service for WebView polling
  ApiService get apiService => _apiService;

  AuthStatus _status = AuthStatus.initial;
  OAuthStatus _oauthStatus = OAuthStatus.idle;
  User? _user;
  String? _userId;
  String? _token;
  String? _error;

  // OAuth flow state
  PKCEParams? _pkceParams;
  OAuthSession? _currentSession;
  Timer? _pollingTimer;
  int _pollingAttempts = 0;

  AuthProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // Getters
  AuthStatus get status => _status;
  OAuthStatus get oauthStatus => _oauthStatus;
  User? get user => _user;
  String? get userId => _userId;
  String? get token => _token;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isOAuthInProgress =>
      _oauthStatus != OAuthStatus.idle &&
      _oauthStatus != OAuthStatus.success &&
      _oauthStatus != OAuthStatus.error &&
      _oauthStatus != OAuthStatus.timeout &&
      _oauthStatus != OAuthStatus.cancelled;
  OAuthSession? get currentSession => _currentSession;
  String? get authorizationUrl => _currentSession?.authorizationUrl;

  // Initialize - check for existing session
  Future<void> initialize() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final savedToken = await _apiService.token;
      final savedUserId = await _apiService.getSavedUserId();
      final savedUser = await _apiService.getSavedUser();

      if (savedToken != null && savedUserId != null) {
        _token = savedToken;
        _userId = savedUserId;
        _user = savedUser;

        // Fetch fresh user profile
        try {
          _user = await _apiService.getUserProfile(savedUserId);
          _status = AuthStatus.authenticated;
        } catch (e) {
          // Token might be expired
          if (e is ApiException && e.statusCode == 401) {
            await _apiService.clearCredentials();
            _status = AuthStatus.unauthenticated;
          } else {
            // Use cached user
            _status = AuthStatus.authenticated;
          }
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error = e.toString();
    }

    notifyListeners();
  }

  // Start OAuth flow
  Future<OAuthSession?> startOAuthFlow({bool useMobileRedirect = false}) async {
    _oauthStatus = OAuthStatus.creatingSession;
    _error = null;
    notifyListeners();

    try {
      // Generate PKCE parameters
      _pkceParams = PKCEUtils.generatePKCEParams();

      // Save PKCE params for later verification
      await _apiService.savePKCEParams(
        _pkceParams!.state,
        _pkceParams!.codeVerifier,
      );

      // Create OAuth session
      _currentSession = await _apiService.createSession(
        state: _pkceParams!.state,
        codeVerifier: _pkceParams!.codeVerifier,
        codeChallenge: _pkceParams!.codeChallenge,
        nonce: _pkceParams!.nonce,
        useMobileRedirect: useMobileRedirect,
      );

      _oauthStatus = OAuthStatus.waitingForAuth;
      notifyListeners();

      return _currentSession;
    } catch (e) {
      _oauthStatus = OAuthStatus.error;
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Start polling for session completion
  void startPolling() {
    if (_currentSession == null) return;

    _oauthStatus = OAuthStatus.polling;
    _pollingAttempts = 0;
    notifyListeners();

    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(milliseconds: AppConstants.sessionPollingIntervalMs),
      (_) => _pollSessionStatus(),
    );
  }

  Future<void> _pollSessionStatus() async {
    if (_currentSession == null) {
      _pollingTimer?.cancel();
      return;
    }

    _pollingAttempts++;

    if (_pollingAttempts > AppConstants.maxPollingAttempts) {
      _pollingTimer?.cancel();
      _oauthStatus = OAuthStatus.timeout;
      _error = 'Authentication timed out. Please try again.';
      notifyListeners();
      return;
    }

    try {
      final status = await _apiService.getSessionStatus(_currentSession!.state);

      if (status.completed && status.token != null && status.userId != null) {
        _pollingTimer?.cancel();
        await completeAuthentication(
          token: status.token!,
          userId: status.userId!,
          name: status.name,
          email: status.email,
        );
      }
    } catch (e) {
      // Continue polling on error, might be temporary
      debugPrint('Polling error: $e');
    }
  }

  // Stop polling
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  // Cancel OAuth flow
  void cancelOAuthFlow() {
    stopPolling();
    _oauthStatus = OAuthStatus.cancelled;
    _currentSession = null;
    _pkceParams = null;
    _apiService.clearPKCEParams();
    notifyListeners();
  }

  // Handle OAuth callback (for deep link handling)
  Future<bool> handleCallback({
    required String code,
    required String state,
    String? jti,
  }) async {
    _oauthStatus = OAuthStatus.exchangingToken;
    notifyListeners();

    try {
      // Verify state matches
      final savedParams = await _apiService.getPKCEParams();
      if (savedParams.state != state) {
        throw Exception('State mismatch - possible CSRF attack');
      }

      final response = await _apiService.handleCallback(
        code: code,
        state: state,
        jti: jti,
      );

      final data = response['data'] as Map<String, dynamic>;
      await completeAuthentication(
        token: data['token'] as String,
        userId: data['userId'] as String,
        name: data['name'] as String?,
        email: data['email'] as String?,
      );

      return true;
    } catch (e) {
      _oauthStatus = OAuthStatus.error;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Complete authentication (public for WebView polling)
  Future<void> completeAuthentication({
    required String token,
    required String userId,
    String? name,
    String? email,
  }) async {
    _token = token;
    _userId = userId;

    // Save credentials
    await _apiService.saveCredentials(token: token, userId: userId);

    // Fetch full user profile
    try {
      _user = await _apiService.getUserProfile(userId);
      await _apiService.saveCredentials(
        token: token,
        userId: userId,
        user: _user,
      );
    } catch (e) {
      // Create minimal user from available data
      _user = User(
        id: userId,
        name: name,
        email: email,
      );
    }

    // Clean up
    await _apiService.clearPKCEParams();
    _currentSession = null;
    _pkceParams = null;

    _oauthStatus = OAuthStatus.success;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  // Refresh user profile
  Future<void> refreshUserProfile() async {
    if (_userId == null) return;

    try {
      _user = await _apiService.getUserProfile(_userId!);
      await _apiService.saveCredentials(
        token: _token!,
        userId: _userId!,
        user: _user,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    stopPolling();
    await _apiService.clearCredentials();
    await _apiService.clearPKCEParams();

    _status = AuthStatus.unauthenticated;
    _oauthStatus = OAuthStatus.idle;
    _user = null;
    _userId = null;
    _token = null;
    _error = null;
    _currentSession = null;
    _pkceParams = null;

    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset OAuth status to idle
  void resetOAuthStatus() {
    _oauthStatus = OAuthStatus.idle;
    _error = null;
    notifyListeners();
  }

  // ==================== Demo Login ====================

  /// Send demo OTP
  Future<bool> demoSendOtp(String phone) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.demoSendOtp(phone);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return response['success'] == true;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Verify demo OTP and login
  Future<bool> demoVerifyOtp(String phone, String otp) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.demoVerifyOtp(phone, otp);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Verification failed');
      }

      final data = response['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final userId = data['userId'].toString();
      final userData = data['user'] as Map<String, dynamic>;

      // Save credentials and complete authentication
      _token = token;
      _userId = userId;
      _user = User.fromJson(userData);

      await _apiService.saveCredentials(
        token: token,
        userId: userId,
        user: _user,
      );

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
