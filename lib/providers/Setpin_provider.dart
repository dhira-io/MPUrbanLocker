// lib/providers/pin_creation_provider.dart
import 'package:flutter/material.dart';

class SetpinProvider with ChangeNotifier {
  String _newPin = '';
  String _confirmPin = '';
  bool _pinSaved = false;

  // Custom message for the UI
  String? _errorMessage;

  // Getters
  String get newPin => _newPin;
  String get confirmPin => _confirmPin;
  bool get pinSaved => _pinSaved;
  String? get errorMessage => _errorMessage;

  // Determines if the 'Save PIN' button should be enabled
  bool get isReadyToSave =>
      _newPin.length == 4 &&
          _confirmPin.length == 4 &&
          _errorMessage == null;

  // Setters
  void setNewPin(String pin) {
    _newPin = pin;
    _validatePins(); // Re-validate every time a digit changes
    notifyListeners();
  }

  void setConfirmPin(String pin) {
    _confirmPin = pin;
    _validatePins(); // Re-validate every time a digit changes
    notifyListeners();
  }

  // Core validation logic
  void _validatePins() {
    // Only check for mismatch if both fields are fully entered
    if (_newPin.length == 4 && _confirmPin.length == 4) {
      if (_newPin != _confirmPin) {
        _errorMessage = "PINs do not match. Please match PINs!";
      } else {
        _errorMessage = null; // Clear error if they match
      }
    } else {
      _errorMessage = null; // Clear error if fields are incomplete
    }
  }

  Future<void> savePin() async {
    if (!isReadyToSave) return;

    _pinSaved = true;
    _errorMessage = null;
    notifyListeners();

    // --- API Call Simulation ---
    try {
      // Simulate network delay for saving the PIN
      await Future.delayed(const Duration(seconds: 1));
      print('New PIN saved successfully: $_newPin');

      // In a real app, navigate to the dashboard/home screen

    } catch (e) {
      _errorMessage = "Failed to save PIN. Try again.";
      _pinSaved = false;
    } finally {
      // For this UI, we keep _pinSaved = true to show success message, 
      // or set it back to false on failure.
      notifyListeners();
    }
  }
}