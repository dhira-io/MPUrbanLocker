import 'package:flutter/material.dart';

import 'dashboard_screen_new.dart';
import 'dashboard_screen_old.dart';

class CombinedDashboard extends StatelessWidget {
  // 1. Define the parameter in the constructor
  final bool isLoggedIn;

  const CombinedDashboard({
    super.key,
    required this.isLoggedIn, // Status is passed directly
  });

  @override
  Widget build(BuildContext context) {
    // 2. Apply the Conditional Logic using the passed parameter
    if (isLoggedIn) {
      // 🟢 User is logged in: Show the new dashboard
      return const DashboardScreen_new();
    } else {
      // 🔴 User is not logged in: Show the old/guest dashboard
      return DashboardScreen_old();
    }
  }
}