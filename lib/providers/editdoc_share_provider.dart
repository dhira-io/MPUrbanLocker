import 'package:flutter/material.dart';

class EditDocShareProvider extends ChangeNotifier {
  final TextEditingController documentController =
  TextEditingController(text: "Driving License.pdf");

  final TextEditingController sharedWithController =
  TextEditingController(text: "S. Singh");

  String selectedMethod = "Secure Link";
  String selectedProtection = "OTP Protected";
  String selectedExpiry = "29 Dec 2025, 07:21 AM";

  final List<String> methods = ["Secure Link"];
  final List<String> protections = ["OTP Protected"];
  final List<String> expiryOptions = [
    "29 Dec 2025, 07:21 AM",
    "30 Dec 2025, 07:21 AM",
  ];

  void setMethod(String value) {
    selectedMethod = value;
    notifyListeners();
  }

  void setProtection(String value) {
    selectedProtection = value;
    notifyListeners();
  }

  void setExpiry(String value) {
    selectedExpiry = value;
    notifyListeners();
  }

  // 🔹 Actions (connect API here)
  void saveDetails() {
    debugPrint("Save Details");
  }

  void revokeLink() {
    debugPrint("Revoke Link");
  }

  void shareDocument() {
    debugPrint("Share Document");
  }

  @override
  void dispose() {
    documentController.dispose();
    sharedWithController.dispose();
    super.dispose();
  }
}
