import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/scheme_model.dart';
import '../utils/constants.dart';

// Import your global navigator key if defined in main.dart
// import '../main.dart';

class SchemeProvider extends ChangeNotifier {
  List<SchemeMatch> _schemes = [];
  bool _isLoading = false;
  String _errorMessage = "";

  List<SchemeMatch> get schemes => _schemes;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  final _storage = const FlutterSecureStorage();

  Future<void> fetchSchemes() async {
    _isLoading = true;
    _errorMessage = "";
    notifyListeners();

    try {
      final accessToken = await _storage.read(key: AppConstants.tokenKey);
      final url = Uri.parse("https://0w5c7rsr-3001.inc1.devtunnels.ms/api/users/me/scheme-matches?min_percentage=0");

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      print("scheme accesstoken =$accessToken");
      print("scheme resp =${response.statusCode}\nresp =${response.body}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);

        // This now works because SchemeResponse handles the 'data' wrapper
        final schemeResponse = SchemeResponse.fromJson(decodedData);
        _schemes = schemeResponse.matches;
      }
      else if (response.statusCode == 401) {
        _errorMessage = "Session expired. Please login again.";
        await handleLogout();
      }
      else {
        _errorMessage = "Server Error: ${response.statusCode}";
      }
    } catch (error) {
      _errorMessage = "Connection error. Please check your internet.";
      debugPrint("Fetch Error: $error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleLogout() async {
    await _storage.deleteAll();
    _schemes = [];
    // If you have a navigatorKey in main.dart:
    // navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
    notifyListeners();
  }
}