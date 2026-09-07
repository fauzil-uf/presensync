import 'package:intl/intl.dart';

class DateFormatter {
  // Greeting based on current hour
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) {
      return 'Selamat Pagi';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  // Indonesian day and full date: "Senin, 07 September 2026"
  static String formatFullDate(DateTime date) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final dayName = days[date.weekday - 1];
    final day = date.day.toString().padLeft(2, '0');
    final monthName = months[date.month - 1];
    final year = date.year;

    return '$dayName, $day $monthName $year';
  }

  // API Format: "yyyy-MM-dd"
  static String formatApiDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Current Time Format: "HH:mm"
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  // Parse string date safely and convert to local timezone (WIB)
  // Returns full format: "Senin, 07 September 2026"
  static String formatFriendly(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return formatFullDate(dt);
    } catch (_) {
      return dateStr;
    }
  }

  // Compact format for info rows: "07 Sep 2026"
  static String formatShort(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    const shortMonths = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = shortMonths[dt.month - 1];
      final year = dt.year;
      return '$day $month $year';
    } catch (_) {
      return dateStr;
    }
  }

  // Format with day name & short month: "Senin, 07 Sep 2026"
  static String formatShortWithDay(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    const days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
    ];
    const shortMonths = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final dayName = days[dt.weekday - 1];
      final day = dt.day.toString().padLeft(2, '0');
      final month = shortMonths[dt.month - 1];
      final year = dt.year;
      return '$dayName, $day $month $year';
    } catch (_) {
      return dateStr;
    }
  }
}
