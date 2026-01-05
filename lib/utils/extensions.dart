import 'package:intl/intl.dart';

extension StringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  String get capitalize {
    if (isNullOrEmpty) return '';
    return '${this![0].toUpperCase()}${this!.substring(1).toLowerCase()}';
  }

  String get capitalizeWords {
    if (isNullOrEmpty) return '';
    return this!.split(' ').map((word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }

  String? get nullIfEmpty => isNullOrEmpty ? null : this;
}

extension DateTimeExtensions on DateTime {
  String get formattedDate => DateFormat('dd MMM yyyy').format(this);
  String get formattedDateTime => DateFormat('dd MMM yyyy, HH:mm').format(this);
  String get formattedTime => DateFormat('HH:mm').format(this);
  String get isoDate => DateFormat('yyyy-MM-dd').format(this);

  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}

extension DateStringExtensions on String? {
  DateTime? get toDateTime {
    if (this == null || this!.isEmpty) return null;
    try {
      return DateTime.parse(this!);
    } catch (_) {
      return null;
    }
  }

  String get formattedDate {
    final date = toDateTime;
    if (date == null) return this ?? '';
    return date.formattedDate;
  }

  String get formattedDateTime {
    final date = toDateTime;
    if (date == null) return this ?? '';
    return date.formattedDateTime;
  }
}

extension ListExtensions<T> on List<T>? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  T? get firstOrNull {
    if (isNullOrEmpty) return null;
    return this!.first;
  }

  T? get lastOrNull {
    if (isNullOrEmpty) return null;
    return this!.last;
  }
}

extension MapExtensions<K, V> on Map<K, V>? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
}
