
import 'package:flutter/material.dart';
import '../models/activity_log_model.dart';
import '../services/api_service.dart';

class ActivityLogProvider with ChangeNotifier {
  final ApiService apiService;
  List<ActivityLogModel> _activities = [];
  bool _isLoading = false;
  String _errorMessage = '';

  ActivityLogProvider(this.apiService) {
    fetchActivities();
  }

  List<ActivityLogModel> get activities => _activities;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchActivities() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Mock data for now, as in the image
      _activities = [
        ActivityLogModel(icon: Icons.credit_card, title: 'Aadhaar Card', subtitle: 'Document Viewed', time: '12:08 PM', dateCategory: 'Today'),
        ActivityLogModel(icon: Icons.credit_card, title: 'Driving License', subtitle: 'Document Shared', time: '11:20 AM', dateCategory: 'Today'),
        ActivityLogModel(icon: Icons.directions_car, title: 'Vehicle Registration Certificate', subtitle: 'Document Shared', time: '4:45 PM', dateCategory: 'Yesterday'),
        ActivityLogModel(icon: Icons.school, title: 'Marksheet / Certificates', subtitle: 'Document Fetched', time: '2:15 PM', dateCategory: 'Yesterday'),
        ActivityLogModel(icon: Icons.fingerprint, title: 'PAN Card', subtitle: 'Download Failed', time: '2:07 PM', dateCategory: 'Yesterday'),
      ];

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
