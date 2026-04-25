/// Utility class for formatting byte sizes into human-readable strings.
///
/// Provides static methods to convert bytes to appropriate units
/// (B, KB, MB, GB) with proper formatting.
class FormatUtils {
  FormatUtils._();

  /// Formats bytes into a human-readable string.
  ///
  /// Examples:
  /// - 1024 bytes -> "1.0 KB"
  /// - 1048576 bytes -> "1.0 MB"
  /// - 1073741824 bytes -> "1.0 GB"
  ///
  /// [bytes] - The size in bytes to format
  /// Returns a formatted string with appropriate unit
  static String formatBytes(double bytes) {
    if (bytes <= 0) return '0 B';

    const int kb = 1024;
    const int mb = kb * 1024;
    const int gb = mb * 1024;

    if (bytes >= gb) {
      return '${(bytes / gb).toStringAsFixed(1)} GB';
    } else if (bytes >= mb) {
      return '${(bytes / mb).toStringAsFixed(1)} MB';
    } else if (bytes >= kb) {
      return '${(bytes / kb).toStringAsFixed(1)} KB';
    } else {
      return '${bytes.toStringAsFixed(0)} B';
    }
  }

  /// Formats a DateTime into a human-readable relative or absolute string.
  ///
  /// Returns strings like "Today", "Yesterday", "3 days ago", or
  /// "Jan 15, 2024" depending on how recent the date is.
  ///
  /// [date] - The date to format
  /// Returns a formatted date string
  static String formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));
    final DateTime fileDate = DateTime(date.year, date.month, date.day);

    if (fileDate == today) {
      return 'Today, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (fileDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return '${_getDayName(date.weekday)}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${_monthName(date.month)} ${date.day}, ${date.year}';
    }
  }

  /// Formats a duration into a human-readable relative time string.
  ///
  /// Returns strings like "Just now", "5 mins ago", "2 hours ago", etc.
  ///
  /// [duration] - The duration to format
  /// Returns a formatted relative time string
  static String formatDuration(Duration duration) {
    if (duration.inMinutes < 1) {
      return 'Just now';
    }
    if (duration.inHours < 1) {
      final int minutes = duration.inMinutes;
      return '$minutes min${minutes == 1 ? '' : 's'} ago';
    }
    if (duration.inDays < 1) {
      final int hours = duration.inHours;
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    }
    if (duration.inDays == 1) {
      return 'Yesterday';
    }
    if (duration.inDays < 7) {
      return '${duration.inDays} days ago';
    }
    return formatDate(DateTime.now().subtract(duration));
  }

  static String _getDayName(int weekday) {
    const List<String> days = <String>[
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
    ];
    return days[weekday - 1];
  }

  static String _monthName(int month) {
    const List<String> months = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }
}