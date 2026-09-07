import 'package:flutter/material.dart';
import '../core/utils/date_formatter.dart';
import '../core/utils/location_helper.dart';
import '../models/attendance_model.dart';
import '../models/attendance_stats_model.dart';
import '../services/attendance_service.dart';
import '../services/dio_client.dart';

class AttendanceViewModel extends ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();

  AttendanceModel? _todayAttendance;
  AttendanceStatsModel? _stats;
  List<AttendanceModel> _historyList = [];

  bool _isLoadingDashboard = false;
  bool _isLoadingHistory = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  LocationResult? _lastKnownLocation;

  AttendanceModel? get todayAttendance {
    if (_todayAttendance != null) return _todayAttendance;
    final todayStr = DateFormatter.formatApiDate(ServerTimeSync.accurateNow);
    try {
      return _historyList.firstWhere(
        (e) =>
            e.attendanceDate == todayStr ||
            e.attendanceDate.startsWith(todayStr),
      );
    } catch (_) {
      return null;
    }
  }

  AttendanceStatsModel? get stats => _stats;
  List<AttendanceModel> get historyList => _historyList;

  bool get isLoadingDashboard => _isLoadingDashboard;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  LocationResult? get lastKnownLocation => _lastKnownLocation;

  // Status Helper
  bool get hasCheckedInToday {
    final item = todayAttendance;
    return item != null &&
        ((item.checkInTime != null && item.checkInTime!.isNotEmpty) ||
            item.isMasuk);
  }

  bool get hasCheckedOutToday {
    final item = todayAttendance;
    return item != null && item.hasCheckOut;
  }

  // --- Analytics & Statistics Computed Helpers ---
  int get totalMasuk => _stats?.totalMasuk ?? _historyList.where((e) => e.isMasuk).length;
  int get totalIzin => _stats?.totalIzin ?? _historyList.where((e) => e.isIzin).length;
  int get totalRecorded => totalMasuk + totalIzin;

  int get onTimeCount => _historyList.where((e) => e.isOnTime).length;
  int get lateCount => _historyList.where((e) => e.isLate).length;

  double get attendancePercentage {
    final total = totalRecorded;
    if (total == 0) return 100.0;
    final masuk = totalMasuk;
    return ((masuk / total) * 100).clamp(0.0, 100.0);
  }

  bool get isPerformanceGood {
    final total = totalRecorded;
    if (total == 0) return true;
    return attendancePercentage >= 80.0;
  }

  String get attendanceGrade {
    final totalRec = totalRecorded;
    if (totalRec == 0) return 'Belum Ada';

    final rate = attendancePercentage;
    final masuk = totalMasuk;
    final onTimeRate = masuk > 0 ? (onTimeCount / masuk * 100) : 0.0;

    // 1. Sangat Baik: Kehadiran >= 90% dengan ketepatan waktu tinggi
    if (rate >= 90.0) {
      if (onTimeRate >= 80.0) return 'Sangat Baik';
      return 'Baik';
    }

    // 2. Baik: Memenuhi standar kelulusan PPKD (>= 80%)
    if (rate >= 80.0) {
      return 'Baik';
    }

    // 3. Cukup: 70% - 79%
    if (rate >= 70.0) {
      return 'Cukup';
    }

    // 4. Perlu Evaluasi: Di bawah 70% (misal 50% karena izin atau kurang hadir)
    return 'Perlu Evaluasi';
  }

  /// Kalimat evaluasi performa kehadiran yang natural, kontekstual & profesional
  String get attendanceHeadline {
    final totalRec = totalRecorded;
    if (totalRec == 0) return 'Belum Ada Catatan Presensi';

    final rate = attendancePercentage;
    final masuk = totalMasuk;
    final izin = totalIzin;
    final lates = lateCount;

    if (rate >= 95.0) {
      if (lates == 0) {
        return 'Presensi Sempurna & Tepat Waktu! 🏆';
      }
      return 'Kehadiran Baik, Tingkatkan Disiplin Waktu';
    }

    if (rate >= 80.0) {
      if (lates == 0) {
        return 'Memenuhi Standar Kelulusan PPKD';
      }
      return 'Memenuhi Standar, Jaga Ketepatan Masuk';
    }

    // Rate < 80% (Di bawah standar kelulusan PPKD min 80%)
    if (izin > 0 && masuk > 0) {
      return 'Perlu Peningkatan Presensi (Ada Izin/Sakit)';
    }

    if (masuk == 0 && izin > 0) {
      return 'Catatan Izin Tercatat, Mulai Presensi Hadir';
    }

    return 'Perlu Peningkatan Kehadiran (Min. 80%)';
  }

  Future<void> refreshAll() async {
    await Future.wait([
      loadDashboard(),
      loadHistory(),
    ]);
  }

  // 1. Muat Dashboard (Status Hari Ini + Statistik)
  Future<void> loadDashboard() async {
    _isLoadingDashboard = true;
    _errorMessage = null;
    notifyListeners();

    final todayStr = DateFormatter.formatApiDate(ServerTimeSync.accurateNow);

    try {
      final results = await Future.wait([
        _attendanceService.getTodayAttendance(todayStr),
        _attendanceService.getStats(),
      ]);

      _todayAttendance = results[0] as AttendanceModel?;
      _stats = results[1] as AttendanceStatsModel?;

      // Jika endpoint today null namun data sudah ada di riwayat, gunakan data riwayat
      if (_todayAttendance == null && _historyList.isNotEmpty) {
        final found = _historyList.where(
          (e) =>
              e.attendanceDate == todayStr ||
              e.attendanceDate.startsWith(todayStr),
        ).toList();
        if (found.isNotEmpty) {
          _todayAttendance = found.first;
        }
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingDashboard = false;
      notifyListeners();
    }
  }

  // 2. Absen Masuk (Check-In)
  Future<bool> checkIn({
    required double lat,
    required double lng,
    required String address,
  }) async {
    // State machine guard
    if (_todayAttendance?.isIzin == true) {
      _errorMessage = 'Anda memiliki status izin aktif untuk hari ini. Tidak dapat absen masuk.';
      notifyListeners();
      return false;
    }
    if (hasCheckedInToday) {
      _errorMessage = 'Anda sudah melakukan absen masuk hari ini.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    // Menggunakan waktu tersinkronisasi server (mencegah manipulasi jam HP)
    final accurateNow = ServerTimeSync.accurateNow;
    final todayStr = DateFormatter.formatApiDate(accurateNow);
    final timeStr = DateFormatter.formatTime(accurateNow);

    try {
      final result = await _attendanceService.checkIn(
        attendanceDate: todayStr,
        checkInTime: timeStr,
        checkInLat: lat,
        checkInLng: lng,
        checkInAddress: address,
      );

      _todayAttendance = result;
      // Refresh stats & history
      await _attendanceService.getStats().then((s) => _stats = s);
      await loadHistory();

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  // 3. Absen Pulang (Check-Out)
  Future<bool> checkOut({
    required double lat,
    required double lng,
    required String address,
  }) async {
    // State machine guard
    if (!hasCheckedInToday) {
      _errorMessage = 'Silakan lakukan absen masuk terlebih dahulu sebelum absen pulang.';
      notifyListeners();
      return false;
    }
    if (hasCheckedOutToday) {
      _errorMessage = 'Anda sudah melakukan absen pulang hari ini.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    // Menggunakan waktu tersinkronisasi server (mencegah manipulasi jam HP)
    final accurateNow = ServerTimeSync.accurateNow;
    final todayStr = DateFormatter.formatApiDate(accurateNow);
    final timeStr = DateFormatter.formatTime(accurateNow);

    try {
      final result = await _attendanceService.checkOut(
        attendanceDate: todayStr,
        checkOutTime: timeStr,
        checkOutLat: lat,
        checkOutLng: lng,
        checkOutAddress: address,
      );

      _todayAttendance = result;
      // Refresh stats & history
      await _attendanceService.getStats().then((s) => _stats = s);
      await loadHistory();

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  // 4. Pengajuan Izin
  Future<bool> submitLeave({
    required String date,
    required String reason,
  }) async {
    final todayStr = DateFormatter.formatApiDate(ServerTimeSync.accurateNow);
    if (date == todayStr && hasCheckedInToday) {
      _errorMessage = 'Anda sudah tercatat hadir hari ini, tidak dapat mengajukan izin untuk tanggal yang sama.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _attendanceService.submitLeave(
        date: date,
        alasanIzin: reason,
      );

      if (date == todayStr) {
        _todayAttendance = result;
      }
      // Refresh stats & history
      await _attendanceService.getStats().then((s) => _stats = s);
      await loadHistory();

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  // 5. Muat Riwayat Absensi
  Future<void> loadHistory() async {
    _isLoadingHistory = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await _attendanceService.getHistory();
      // Urutkan riwayat dari yang terbaru ke terlama
      list.sort((a, b) => b.attendanceDate.compareTo(a.attendanceDate));
      _historyList = list;

      if (_todayAttendance == null) {
        final todayStr = DateFormatter.formatApiDate(ServerTimeSync.accurateNow);
        final found = _historyList.where(
          (e) =>
              e.attendanceDate == todayStr ||
              e.attendanceDate.startsWith(todayStr),
        ).toList();
        if (found.isNotEmpty) {
          _todayAttendance = found.first;
        }
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  // 6. Hapus Absen
  Future<bool> deleteAttendance(int id) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _attendanceService.deleteAttendance(id);
      _historyList.removeWhere((item) => item.id == id);

      if (_todayAttendance != null && _todayAttendance!.id == id) {
        _todayAttendance = null;
      }

      // Refresh stats
      await _attendanceService.getStats().then((s) => _stats = s);

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  // Refresh current location
  Future<LocationResult> fetchLocation() async {
    final result = await LocationHelper.getCurrentLocationWithAddress();
    _lastKnownLocation = result;
    notifyListeners();
    return result;
  }

  // Reset all state (membersihkan data saat logout agar tidak bocor ke user lain)
  void reset() {
    _todayAttendance = null;
    _stats = null;
    _historyList = [];
    _lastKnownLocation = null;
    _errorMessage = null;
    _isLoadingDashboard = false;
    _isLoadingHistory = false;
    _isSubmitting = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

// Backward compatibility alias
typedef AttendanceProvider = AttendanceViewModel;
