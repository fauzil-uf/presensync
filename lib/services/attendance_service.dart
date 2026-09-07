import 'package:dio/dio.dart';
import '../models/attendance_model.dart';
import '../models/attendance_stats_model.dart';
import 'api_service.dart';
import 'auth_storage.dart';
import 'dio_client.dart';

class AttendanceService {
  final Dio _dio;
  final ApiService api;

  Dio get dio => _dio;

  AttendanceService({Dio? dio, ApiService? api})
      : _dio = dio ?? DioClient.createDio(),
        api = api ?? ApiService(dio ?? DioClient.createDio());

  factory AttendanceService.create() {
    final dio = DioClient.createDio();
    return AttendanceService(dio: dio, api: ApiService(dio));
  }

  Future<String> _getAuthHeader() async {
    final token = await AuthStorage.getToken();
    return 'Bearer ${token ?? ''}';
  }

  // 1. Absen Masuk (Check-In)
  Future<AttendanceModel> checkIn({
    required String attendanceDate,
    required String checkInTime,
    double? lat,
    double? lng,
    String? address,
    double? checkInLat,
    double? checkInLng,
    String? checkInAddress,
  }) async {
    try {
      final header = await _getAuthHeader();
      final latitude = checkInLat ?? lat ?? 0.0;
      final longitude = checkInLng ?? lng ?? 0.0;
      final addr = checkInAddress ?? address ?? 'Jakarta';

      final resp = await api.checkIn(header, {
        'attendance_date': attendanceDate,
        'check_in': checkInTime,
        'check_in_lat': latitude,
        'check_in_lng': longitude,
        'check_in_address': addr,
        'status': 'masuk',
      });

      if (resp is Map<String, dynamic> && resp['data'] is Map<String, dynamic>) {
        return AttendanceModel.fromJson(resp['data'] as Map<String, dynamic>);
      }
      throw Exception('Format respons tidak valid');
    } catch (e) {
      throw Exception(DioClient.parseErrorMessage(e));
    }
  }

  // 2. Absen Keluar (Check-Out)
  Future<AttendanceModel> checkOut({
    required String attendanceDate,
    required String checkOutTime,
    double? lat,
    double? lng,
    String? address,
    double? checkOutLat,
    double? checkOutLng,
    String? checkOutAddress,
  }) async {
    try {
      final header = await _getAuthHeader();
      final latitude = checkOutLat ?? lat ?? 0.0;
      final longitude = checkOutLng ?? lng ?? 0.0;
      final addr = checkOutAddress ?? address ?? 'Jakarta';

      final resp = await api.checkOut(header, {
        'attendance_date': attendanceDate,
        'check_out': checkOutTime,
        'check_out_lat': latitude,
        'check_out_lng': longitude,
        'check_out_address': addr,
      });

      if (resp is Map<String, dynamic> && resp['data'] is Map<String, dynamic>) {
        return AttendanceModel.fromJson(resp['data'] as Map<String, dynamic>);
      }
      throw Exception('Format respons tidak valid');
    } catch (e) {
      throw Exception(DioClient.parseErrorMessage(e));
    }
  }

  // 3. Pengajuan Izin
  Future<AttendanceModel> submitLeave({
    required String date,
    String? reason,
    String? alasanIzin,
  }) async {
    try {
      final header = await _getAuthHeader();
      final finalReason = alasanIzin ?? reason ?? '';

      final resp = await api.submitLeave(header, {
        'date': date,
        'alasan_izin': finalReason,
      });

      if (resp is Map<String, dynamic> && resp['data'] is Map<String, dynamic>) {
        return AttendanceModel.fromJson(resp['data'] as Map<String, dynamic>);
      }
      throw Exception('Format respons tidak valid');
    } catch (e) {
      throw Exception(DioClient.parseErrorMessage(e));
    }
  }

  // 4. Absen Hari Ini
  Future<AttendanceModel?> getTodayAttendance(String attendanceDate) async {
    try {
      final header = await _getAuthHeader();
      final resp = await api.getTodayAttendance(header, attendanceDate);
      if (resp is Map<String, dynamic> && resp['data'] is Map<String, dynamic>) {
        return AttendanceModel.fromJson(resp['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // 5. Statistik Absen
  Future<AttendanceStatsModel> getStats({
    String? year,
    String? start,
    String? end,
  }) => getAttendanceStats(year: year, start: start, end: end);

  Future<AttendanceStatsModel> getAttendanceStats({
    String? year,
    String? start,
    String? end,
  }) async {
    try {
      final header = await _getAuthHeader();
      final resp = await api.getAttendanceStats(header, year, start, end);
      if (resp is Map<String, dynamic> && resp['data'] is Map<String, dynamic>) {
        return AttendanceStatsModel.fromJson(
          resp['data'] as Map<String, dynamic>,
        );
      }
      return AttendanceStatsModel(
        totalAbsen: 0,
        totalMasuk: 0,
        totalIzin: 0,
        sudahAbsenHariIni: false,
      );
    } catch (_) {
      return AttendanceStatsModel(
        totalAbsen: 0,
        totalMasuk: 0,
        totalIzin: 0,
        sudahAbsenHariIni: false,
      );
    }
  }

  // 6. Riwayat Absen
  Future<List<AttendanceModel>> getHistory() => getAttendanceHistory();

  Future<List<AttendanceModel>> getAttendanceHistory() async {
    try {
      final header = await _getAuthHeader();
      final resp = await api.getAttendanceHistory(header);
      final list = <AttendanceModel>[];
      if (resp is Map<String, dynamic> && resp['data'] is List) {
        for (final item in resp['data'] as List) {
          if (item is Map<String, dynamic>) {
            list.add(AttendanceModel.fromJson(item));
          }
        }
      }
      return list;
    } catch (e) {
      throw Exception(DioClient.parseErrorMessage(e));
    }
  }

  // 7. Hapus Absen
  Future<bool> deleteAttendance(int id) async {
    try {
      final header = await _getAuthHeader();
      await api.deleteAttendance(header, id);
      return true;
    } catch (e) {
      throw Exception(DioClient.parseErrorMessage(e));
    }
  }
}
