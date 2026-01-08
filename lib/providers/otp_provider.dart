// lib/providers/otp_provider.dart
import 'dart:async';
import 'package:digilocker_flutter/screens/set_pin_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/combine_dashboard.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class OTPProvider with ChangeNotifier {
  static const int _initialTimerDuration = 60; // 60 seconds

  // State variables
  String _otpCode = '';
  int _remainingTime = _initialTimerDuration;
  bool _isVerificationLoading = false;
  Timer? _timer;

  // Getters for the UI to consume
  String get otpCode => _otpCode;

  int get remainingTime => _remainingTime;

  bool get isVerificationLoading => _isVerificationLoading;

  bool get isResendEnabled => _remainingTime == 0;

  // Logic to check if the OTP is fully entered (e.g., 6 digits)
  bool get isCodeComplete => _otpCode.length == 6;

  OTPProvider() {
    startTimer(); // Start the timer immediately when the provider is created
  }

  void startTimer() {
    _remainingTime = _initialTimerDuration;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
      } else {
        _timer?.cancel();
      }
      notifyListeners(); // Update the UI every second
    });
  }

  void setOTPCode(String code) {
    _otpCode = code;
    notifyListeners();
  }

  Future<void> verifyOTP(BuildContext context, String phone) async {
    if (!isCodeComplete) return;

    _isVerificationLoading = true;
    notifyListeners();

    _timer?.cancel(); // Stop the timer while verification is ongoing

    // --- Verification API Call Simulation ---
    try {
      Map<String, dynamic> response = await ApiService().demoVerifyOtp(
        phone,
        _otpCode,
      );

      print(response);
      if (response["success"] == true) {
        print(response["data"]);
        String userId = response["data"]["userId"];
        String token = response["data"]["token"];
      final pref = await SharedPreferences.getInstance();
       pref.setString(AppConstants.tokenKey, token);
       pref.setString(AppConstants.userIdKey, userId);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CombinedDashboard(isLoggedIn: true),
          ),
        );
        // if (_otpCode == '123456') { // Simple hardcoded success for demo
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Verification Successful!')),
        //   );

        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (_) => SetPinScreen()),
        // );
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (_) => SetPinScreen()),
        // );
        // In a real app, navigate to the main dashboard
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP. Please try again.')),
        );
        // If failed, you might restart the timer or prompt for resend
      }
    } catch (e) {
      print('Error verifying OTP: $e');
    } finally {
      _isVerificationLoading = false;
      notifyListeners();
    }
  }

  void resendOTP(BuildContext context) {
    // In a real app, call your Resend OTP API here
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Resending OTP...')));
    startTimer(); // Restart the timer
  }

  // Important: Dispose of the timer when the provider is no longer needed
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
