import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String toFormattedString({String format = 'yyyy-MM-dd'}) {
    return DateFormat(format).format(this);
  }

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  String toTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 8) {
      return toFormattedString();
    } else if ((difference.inDays / 7).floor() >= 1) {
      return '1 week ago';
    } else if (difference.inDays >= 2) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays >= 1) {
      return '1 day ago';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} hours ago';
    } else if (difference.inHours >= 1) {
      return '1 hour ago';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inMinutes >= 1) {
      return '1 minute ago';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} seconds ago';
    } else {
      return 'Just now';
    }
  }
}
