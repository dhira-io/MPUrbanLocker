
import 'package:flutter/material.dart';

class ActivityLogModel {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final String dateCategory;

  ActivityLogModel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.dateCategory,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      icon: _mapIcon(json['type']), // Assuming 'type' determines the icon
      title: json['title'] as String,
      subtitle: json['description'] as String,
      time: json['time'] as String,
      dateCategory: json['dateCategory'] as String,
    );
  }

  static IconData _mapIcon(String type) {
    switch (type) {
      case 'view':
        return Icons.visibility;
      case 'share':
        return Icons.share;
      case 'fetch':
        return Icons.cloud_download;
      case 'download_failed':
        return Icons.error;
      default:
        return Icons.info;
    }
  }
}
