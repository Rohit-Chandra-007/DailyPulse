import 'package:intl/intl.dart';

class DateUtils {
  static String getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  static String formatTime(DateTime timestamp) {
    return DateFormat('hh:mm a').format(timestamp);
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMMM d, y').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('MMMM d').format(date);
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static DateTime stripTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
