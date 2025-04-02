class DateTimeUtils {
  /// Formats a DateTime to a string in the format of "h:mm AM/PM"
  static String formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour == 0 ? 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    
    return '$hour:$minute $period';
  }
  
  /// Formats a DateTime to a date string in the format of "MMM dd, yyyy"
  static String formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final month = months[date.month - 1];
    final day = date.day.toString();
    final year = date.year.toString();
    
    return '$month $day, $year';
  }
  
  /// Formats a DateTime to a complete date and time string
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)}, ${formatTime(dateTime)}';
  }
} 