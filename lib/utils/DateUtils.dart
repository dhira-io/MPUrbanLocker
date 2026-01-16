import 'package:intl/intl.dart';

class DateUtils{
  static String formatDate(DateTime isoDate) {
    final localDate = isoDate.toLocal(); // IST
    return DateFormat("dd MMM yyyy . hh:mm a").format(localDate);
  }
}