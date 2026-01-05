import 'package:flutter/material.dart';

class DocServiceConfig {
  final String type;
  final String displayName;
  final String serviceType;
  final String imagePath;
  final Color bgcolor;
  final List<FieldConfig> fields;

  DocServiceConfig({
    required this.type,
    required this.displayName,
    required this.serviceType,
    required this.imagePath,
    required this.bgcolor,
    required this.fields,
  });

  factory DocServiceConfig.fromJson(Map<String, dynamic> json) {
    return DocServiceConfig(
      type: json['type'],
      displayName: json['displayName'],
      serviceType: json['serviceType'],
      imagePath: json['imagePath'],
      bgcolor: _parseColor(json['bgcolor']),
      fields: (json['fields'] as List)
          .map((e) => FieldConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static Color _parseColor(dynamic value) {
    if (value is int) {
      return Color(value);
    } else if (value is String) {
      // Support both "#RRGGBB" and "#AARRGGBB"
      var hex = value.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex'; // add opacity if absent
      }
      return Color(int.parse(hex, radix: 16));
    }
    return Colors.transparent;
  }
}

class FieldConfig {
  final String key;
  final String? certificatetype;
  final String? certificatename;
  final String label;
  final String hint;
  final String type;
  final bool required;
  final int? maxLength;

  FieldConfig({
    required this.key,
    required this.certificatetype,
    required this.certificatename,
    required this.label,
    required this.hint,
    required this.type,
    required this.required,
    this.maxLength,
  });

  factory FieldConfig.fromJson(Map<String, dynamic> json) {
    return FieldConfig(
      key: json['key'],
      certificatetype: json['certificatetype'],
      certificatename: json['certificatename'],
      label: json['label'],
      hint: json['hint'],
      type: json['type'],
      required: json['required'],
      maxLength: json['maxLength'],
    );
  }
}
