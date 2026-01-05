// lib/providers/login_provider.dart
import 'package:flutter/material.dart';

import '../screens/otp_screen.dart';
import '../services/api_service.dart';

class LoginProvider with ChangeNotifier {
  String _inputID = '';
  bool _isLoading = false;

  String get inputID => _inputID;
  bool get isLoading => _isLoading;

  // Simple validation: requires at least 10 characters (for mobile/Aadhaar)
  bool get isInputValid => _inputID.length >= 10;

  void setInputID(String value) {
    _inputID = value;
    notifyListeners(); // Tells the UI to rebuild when the ID changes
  }

  Future<void> sendOTP(context) async {
    if (!isInputValid) return; // Should not happen if button is disabled

    _isLoading = true;
    notifyListeners(); // Start loading state
    // --- API Call Simulation ---
    try {
      final response = await ApiService().demoSendOtp(_inputID);
      //  _status = AuthStatus.unauthenticated;
      // notifyListeners();
      // return response['success'] == true;
      _isLoading = false;
      notifyListeners();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OTPScreen(verificationTarget: _inputID,)),
      );
    } catch (e) {
      // _status = AuthStatus.unauthenticated;
      //  _error = e.toString();
      print('${e.toString()}');
      _isLoading = false;
      notifyListeners();
      // return false;
    }
    // try {
    //   // Simulate network call delay
    //   await Future.delayed(const Duration(seconds: 2));
    //   print('OTP Request Sent for ID: $_inputID');
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (_) => OTPScreen(verificationTarget: '9698000011',)),
    //   );
    //   // In a real app, you would handle successful navigation here
    //   // For demonstration, we just print the status.
    //
    //
    //
    // } catch (e) {
    //   print('Error sending OTP: $e');
    //   // In a real app, show an error message (e.g., a SnackBar)
    // } finally {
    //   _isLoading = false;
    //   notifyListeners(); // End loading state
    // }
  }
}