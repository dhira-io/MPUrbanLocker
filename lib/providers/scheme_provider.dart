import 'dart:convert';
import 'package:digilocker_flutter/models/documentExpiry_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scheme_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import 'package:provider/provider.dart';

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
  Future<void> fetchSchemes(BuildContext context) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final apiService = context.read<ApiService>();

      final Map<String, dynamic> response = await apiService.getRequest(
        AppConstants.schemeMatchesEndpoint,
        includeAuth: true,
      );

      if (response['success'] == true && response['data'] != null) {
        final Map<String, dynamic> decodedData = response;
        final schemeResponse = SchemeResponse.fromJson(decodedData);
        _allSchemes = schemeResponse.matches; // store original
        _schemes = _allSchemes;
      } else {
        _errorMessage = response['message'] ?? 'Something went wrong';
        Fluttertoast.showToast(msg: _errorMessage);
      }
    } on NoInternetException catch (e) {
      _errorMessage = e.toString();
      Fluttertoast.showToast(msg: _errorMessage);
    } catch (e) {
      _errorMessage = 'Failed to load schemes';
      debugPrint('Fetch Error: $e');
      Fluttertoast.showToast(msg: _errorMessage);
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
  Future<void> fetchDocumentsExpiry(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final apiService = context.read<ApiService>();

      final Map<String, dynamic> response = await apiService.getRequest(
        AppConstants.documentsExpiryEndpoint,
        includeAuth: true,
      );
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> docList = response['data'] ?? [];
        _documents = docList
            .map((item) => DocumentExpiry.fromJson(item))
            .toList();
      } else {
        _errorMessage = response['message'] ?? 'Something went wrong';
        Fluttertoast.showToast(msg: _errorMessage);
      }
    } on NoInternetException catch (e) {
      _errorMessage = e.toString();
      Fluttertoast.showToast(msg: _errorMessage);
    } catch (e) {
      _errorMessage = 'Failed to Fetch Documents';
      debugPrint('Fetch Documents Error: $e');
      Fluttertoast.showToast(msg: _errorMessage);
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
