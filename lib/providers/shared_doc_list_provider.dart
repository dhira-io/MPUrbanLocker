
import 'package:flutter/material.dart';

class SharedDocListProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> documents = [
    {
      "title": "Driving License",
      "sharedWith": "S. Singh",
      "file": "Driving License.pdf",
      "method": "Secure Link",
      "protection": "OTP Protected",
      "permission": "View & Download",
      "expiry": "29 Dec 2025, 07:21 AM",
      "icon": Icons.badge,
    },
    {
      "title": "Driving License",
      "sharedWith": "R. Kumar",
      "file": "Driving License.pdf",
      "method": "Secure Link",
      "protection": "OTP Protected",
      "permission": "View Only",
      "expiry": "01 Jan 2026, 10:00 AM",
      "icon": Icons.badge,
    },
    {
      "title": "Vehicle Registration Certificate",
      "sharedWith": "Tarun J.",
      "file": "RC.pdf",
      "method": "Secure Link",
      "protection": "OTP Protected",
      "permission": "View Only",
      "expiry": "15 Feb 2026, 09:00 AM",
      "icon": Icons.directions_car,
    },
    {
      "title": "Marksheet / Certificates",
      "sharedWith": "R. Kumar",
      "file": "Marksheet.pdf",
      "method": "Secure Link",
      "protection": "OTP Protected",
      "permission": "View & Download",
      "expiry": "30 Jun 2026, 06:30 PM",
      "icon": Icons.school,
    },
  ];

  late List<bool> expanded;

  SharedDocListProvider() {
    expanded = List.generate(documents.length, (_) => false);
  }

  void toggleExpanded(int index) {
    expanded[index] = !expanded[index];
    notifyListeners();
  }

  bool isExpanded(int index) => expanded[index];
}
