import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ApplicationStatusResponse.dart';

class LicenseProvider with ChangeNotifier {
  bool isLoading = false;
  ApplicationStatusResponse? appStatus;
  String? error;

  final String baseUrl = "https://api.drivinglicense.gov.in/v1";

  Future<void> fetchApplicationStatus(String applicationId) async {
    final prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString('accessToken') ?? '';

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final uri = Uri.parse("$baseUrl/applications/$applicationId/status");

      final res = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      print("driving lic url = $uri, statuscode = ${res.statusCode}");

      if (res.statusCode >= 200 && res.statusCode < 300) {
        appStatus = ApplicationStatusResponse.fromJson(jsonDecode(res.body));
      } else {
        error = "Failed: ${res.statusCode}";
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
