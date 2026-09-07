class ApiEndpoints {
  static const String baseUrl = 'https://appabsensi.mobileprojp.com/api';

  // Auth & Profile
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String updateProfile = '/profile';
  static const String updateProfilePhoto = '/profile/photo';
  static const String trainings = '/trainings';
  static const String batches = '/batches';
  static const String users = '/users';
  static const String deviceToken = '/device-token';

  // Absensi (Attendance)
  static const String checkIn = '/absen/check-in';
  static const String checkOut = '/absen/check-out';
  static const String izin = '/izin';
  static const String today = '/absen/today';
  static const String stats = '/absen/stats';
  static const String history = '/absen/history';
  static String deleteAbsen(int id) => '/absen/$id';
}
