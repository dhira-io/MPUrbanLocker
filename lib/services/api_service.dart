import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import '../models/document.dart';
import '../models/session.dart';
import '../models/user.dart';
import '../screens/combine_dashboard.dart';
import '../utils/constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class ApiService {
  final String baseUrl;
  // final FlutterSecureStorage _secureStorage;
  final http.Client _client;

  ApiService({
    String? baseUrl,
    // FlutterSecureStorage? secureStorage,
    http.Client? client,
  }) : baseUrl = baseUrl ?? AppConstants.baseUrl,
       // _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _client = client ?? http.Client();

  getauthToken()async{
    final pref = await SharedPreferences.getInstance();
    return await pref.getString(AppConstants.tokenKey) ?? '';

  }
  // Future<String?> get token async =>
  //     await _secureStorage.read(key: AppConstants.tokenKey);

  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final pref = await SharedPreferences.getInstance();
      final authToken =  await pref.getString(AppConstants.tokenKey);
      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
        print("token- $authToken");
      }
    }

    return headers;
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    print(body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
       return body;
      }

    if (response.statusCode == 401) {
      // Token expired or invalid - clear storage
      final pref = await SharedPreferences.getInstance();
      await pref.clear();
      showSessionExpireAlert();
      throw ApiException(
        body['error'] ?? 'Unauthorized',
        statusCode: 401,
        data: body,
      );

    }

    throw ApiException(
      body['error'] ?? body['message'] ?? 'Request failed',
      statusCode: response.statusCode,
      data: body,
    );
  }
  showSessionExpireAlert(){
    Get.dialog(
      AlertDialog(
        title: const Text('Session Expired'),
        content: const Text('Your session has expired. Please login again.'),
        actions: [
          TextButton(
            onPressed: () {
              // Close dialog
              Get.back();
              // Navigate to Login and clear stack
              Get.offAll(() => CombinedDashboard(isLoggedIn: false));
            },
            child: const Text('OK'),
          ),
        ],
      ),
      barrierDismissible: false, // user must tap OK
    );
  }

  // ==================== OAuth Session ====================

  Future<OAuthSession> createSession({
    required String state,
    required String codeVerifier,
    required String codeChallenge,
    required String nonce,
    bool useMobileRedirect = false,
  }) async {
    final requestBody = {
      'state': state,
      'codeVerifier': codeVerifier,
      'codeChallenge': codeChallenge,
      'nonce': nonce,
      'useMobileRedirect': useMobileRedirect,
    };
    debugPrint('📤 Creating session with: $requestBody');
    Map<String, dynamic> body = await postRequest(
      AppConstants.sessionEndpoint,
      includeAuth: false,
      body: requestBody,
    );
    debugPrint('📤 session response: ${body}');
    return OAuthSession.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<SessionStatus> getSessionStatus(String state) async {
    String endpoint = "${AppConstants.sessionStatusEndpoint}/$state/status";
    Map<String, dynamic> body = await getRequest(endpoint, includeAuth: false);
    debugPrint('📤 session response: ${body}');
    return SessionStatus.fromJson(body);
  }

  Future<Map<String, dynamic>> handleCallback({
    required String code,
    required String state,
    String? jti,
  }) async {
    Map<String, dynamic> response = await postRequest(
      AppConstants.callbackEndpoint,
      includeAuth: false,
      body: {'code': code, 'state': state, if (jti != null) 'jti': jti},
    );
    return response;
  }

  // ==================== User Profile ====================

  Future<User> getUserProfile(String userId) async {
    Map<String, dynamic> response = await getRequest(
      "${AppConstants.userProfileEndpoint}",
      includeAuth: true,
    );
    return User.fromJson(response as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getProfileInfo(String userId) async {
    Map<String, dynamic> response = await getRequest(
      "${AppConstants.userProfileEndpoint}",
      includeAuth: true,
    );
    return response;
  }

  // ==================== Demo Login ====================

  Future<Map<String, dynamic>> demoSendOtp(String phone) async {
    Map<String, dynamic> response = await postRequest(
      "${AppConstants.demoSendOTPEndpoint}",
      includeAuth: false,
      body: {'phone': phone},
    );
    return response;
  }

  Future<Map<String, dynamic>> demoVerifyOtp(String phone, String otp) async {
    Map<String, dynamic> response = await postRequest(
      "${AppConstants.demoVerifyOTPEndpoint}",
      includeAuth: false,
      body: {'phone': phone, 'otp': otp},
    );
    return response;
  }

  // ==================== Storage Helpers ====================

  Future<void> saveCredentials({
    required String token,
    required String userId,
    User? user,
  }) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(AppConstants.tokenKey, token);
    await pref.setString(AppConstants.userIdKey, userId);
    if (user != null) {
      await pref.setString(AppConstants.userKey, jsonEncode(user.toJson()));
    }
  }

  Future<void> clearCredentials() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove(AppConstants.tokenKey);
    await pref.remove(AppConstants.userIdKey);
    await pref.remove(AppConstants.userKey);
  }

  Future<String?> getSavedUserId() async {
    final pref = await SharedPreferences.getInstance();
    return await pref.getString(AppConstants.userIdKey);
  }

  Future<User?> getSavedUser() async {
    final pref = await SharedPreferences.getInstance();
    final userJson = await pref.getString(AppConstants.userKey);
    if (userJson == null) return null;
    try {
      return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> savePKCEParams(String state, String verifier) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(AppConstants.pkceStateKey, state);
    await pref.setString(AppConstants.pkceVerifierKey, verifier);
  }

  Future<({String? state, String? verifier})> getPKCEParams() async {
    final pref = await SharedPreferences.getInstance();
    final state = await pref.getString(AppConstants.pkceStateKey);
    final verifier = await pref.getString(AppConstants.pkceVerifierKey);
    return (state: state, verifier: verifier);
  }

  Future<void> clearPKCEParams() async {
    final pref = await SharedPreferences.getInstance();
   await pref.remove(AppConstants.pkceStateKey);
    await pref.remove(AppConstants.pkceVerifierKey);
  }

  void dispose() {
    _client.close();
  }

  Future<Map<String, dynamic>> submitCustomService({
    required String accessToken,
    required String endpoint,
    required Map<String, dynamic> payload,
  }) async {
    return await postRequest(endpoint, includeAuth: true, body: payload);
  }


  Future<Map<String, dynamic>> postRequest(
    String endpoint, {
    bool includeAuth = true,
    Map<String, dynamic>? body,
  }) async {
    try {
      await _checkInternet();
print('$baseUrl$endpoint');
print(body);
      final response = await _client
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: await _getHeaders(includeAuth: includeAuth),
            body: jsonEncode(body ?? {}),
          )
          .timeout(const Duration(seconds: 30));

      return await _handleResponse(response);
    } on NoInternetException {
      rethrow;
    } on Exception catch (e) {
      print(e.toString());
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> putRequest(
      String endpoint, {
        bool includeAuth = true,
        Map<String, dynamic>? body,
      }) async {
    try {
      await _checkInternet();
      print('$baseUrl$endpoint');
      print(body);
      final response = await _client
          .put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(includeAuth: includeAuth),
        body: jsonEncode(body ?? {}),
      )
          .timeout(const Duration(seconds: 30));

      return await _handleResponse(response);
    } on NoInternetException {
      rethrow;
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> getRequest(
    String endpoint, {
    bool includeAuth = true,
    Map<String, String>? queryParams,
  }) async {
    try {
      await _checkInternet();

      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParams);

      final response = await _client
          .get(uri, headers: await _getHeaders(includeAuth: includeAuth))
          .timeout(const Duration(seconds: 30));

      return await _handleResponse(response);
    } on NoInternetException {
      rethrow;
    } on Exception catch (e) {
      print(e.toString());
      throw ApiException(e.toString());
    }
  }
  Future<Map<String, dynamic>> deleteRequest(
      String endpoint, {
        bool includeAuth = true,
        Map<String, String>? queryParams,
      }) async {
    try {
      await _checkInternet();
      print('$baseUrl$endpoint');
      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParams);

      final response = await _client
          .delete(uri, headers: await _getHeaders(includeAuth: includeAuth))
          .timeout(const Duration(seconds: 30));

      return await _handleResponse(response);
    } on NoInternetException {
      rethrow;
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> _checkInternet() async {
    bool internet_status = await CheckInternet.isInternetAvailable();
    if (internet_status == false) {
      throw NoInternetException();
    }
  }
}

class NoInternetException implements Exception {
  final String message;

  NoInternetException([this.message = 'No internet connection']);

  @override
  String toString() => message;
}

class CheckInternet {
  static Future<bool> isInternetAvailable() async {
    final result = await Connectivity().checkConnectivity();
    print("internet status ${result}");
    if (result[0] == ConnectivityResult.none) {
      return false;
    }
    return true;
  }

 static showNoInternetToast(){
   Fluttertoast.showToast(msg: 'No internet connection');
 }
}
