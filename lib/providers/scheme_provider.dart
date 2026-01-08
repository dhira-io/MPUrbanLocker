import 'dart:convert';
import 'package:digilocker_flutter/models/documentExpiry_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scheme_model.dart';
import '../utils/constants.dart';

// Import your global navigator key if defined in main.dart
// import '../main.dart';

class SchemeProvider extends ChangeNotifier {
  List<SchemeMatch> _schemes = [];
  List<SchemeMatch> _allSchemes = []; // 🔹 original data
  List<DocumentExpiry> _documents = []; // New list for documents

  bool _isLoading = false;
  String _errorMessage = "";

  List<SchemeMatch> get schemes => _schemes;
  List<DocumentExpiry> get documents => _documents; // Getter for docs
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;


  // --- API 1: Fetch Schemes ---
  Future<void> fetchSchemes() async {
    _isLoading = true;
    _errorMessage = "";
    notifyListeners();

    try {
      final pref = await SharedPreferences.getInstance();
      final accessToken = await pref.getString(AppConstants.tokenKey);
      final url = Uri.parse(
        "https://0w5c7rsr-3001.inc1.devtunnels.ms/api/users/me/scheme-matches?min_percentage=0",
      );

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        final schemeResponse = SchemeResponse.fromJson(decodedData);

        _allSchemes = schemeResponse.matches; // 🔹 store original
        _schemes = _allSchemes;               // 🔹 visible list
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

  /// 🔍 SEARCH FUNCTION
  void searchSchemes(String query) {
    if (query.trim().isEmpty) {
      _schemes = _allSchemes;
    } else {
      final lowerQuery = query.toLowerCase();
      _schemes = _allSchemes.where((scheme) {
        return scheme.schemeName.toLowerCase().contains(lowerQuery);
        //||
        // scheme.issuingAuthority.toLowerCase().contains(lowerQuery) ||
        // scheme.summary.toLowerCase().contains(lowerQuery);
      }).toList();
    }
    notifyListeners();
  }

  /// ❌ CLEAR SEARCH (optional)
  void clearSearch() {
    _schemes = _allSchemes;
    notifyListeners();
  }

  // --- API 2: Fetch Document Expiry ---
  Future<void> fetchDocumentsExpiry() async {
    _isLoading = true;
    notifyListeners();

    try {
      final pref = await SharedPreferences.getInstance();
      final accessToken = await pref.getString(AppConstants.tokenKey);
      final url = Uri.parse("https://0w5c7rsr-3001.inc1.devtunnels.ms/api/users/me/documents-expiry");

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      print("expiry doc =${response.statusCode}\nresp =${response.body}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        final List<dynamic> docList = decodedData['data'] ?? [];

        _documents = docList.map((item) => DocumentExpiry.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        await handleLogout();
      }
    } catch (error) {
      debugPrint("Fetch Documents Error: $error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleLogout() async {
    final pref = await SharedPreferences.getInstance();
    pref.clear();
    _schemes = [];
    _allSchemes = [];
    _documents = [];
    _errorMessage = "Session expired. Please login again.";
    notifyListeners();
  }
}