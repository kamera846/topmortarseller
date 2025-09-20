import 'package:intl/intl.dart';

class MyDateFormat {
  static String formatDate(
    String dateString, {
    String outputFormat = 'dd MMMM yyyy',
  }) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat(outputFormat, 'id_ID').format(date);
    } catch (e) {
      return '-';
    }
  }

  static String formatDateTime(
    String dateString, {
    String outputFormat = 'dd MMMM yyyy - HH:mm:ss',
  }) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat(outputFormat, 'id_ID').format(date);
    } catch (e) {
      return '-';
    }
  }
}
