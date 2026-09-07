import 'package:json_annotation/json_annotation.dart';

part 'attendance_model.g.dart';

@JsonSerializable(explicitToJson: true)
class AttendanceModel {
  final int id;
  @JsonKey(name: 'user_id')
  final int? userId;
  @JsonKey(name: 'attendance_date')
  final String attendanceDate;
  @JsonKey(name: 'check_in_time')
  final String? checkInTime;
  @JsonKey(name: 'check_out_time')
  final String? checkOutTime;
  @JsonKey(name: 'check_in_address')
  final String? checkInAddress;
  @JsonKey(name: 'check_out_address')
  final String? checkOutAddress;
  @JsonKey(name: 'check_in_location')
  final String? checkInLocation;
  @JsonKey(name: 'check_out_location')
  final String? checkOutLocation;
  @JsonKey(name: 'check_in_lat')
  final double? checkInLat;
  @JsonKey(name: 'check_in_lng')
  final double? checkInLng;
  @JsonKey(name: 'check_out_lat')
  final double? checkOutLat;
  @JsonKey(name: 'check_out_lng')
  final double? checkOutLng;
  @JsonKey(defaultValue: 'masuk')
  final String status; // 'masuk', 'izin'
  @JsonKey(name: 'alasan_izin')
  final String? alasanIzin;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  AttendanceModel({
    required this.id,
    this.userId,
    required this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.checkInAddress,
    this.checkOutAddress,
    this.checkInLocation,
    this.checkOutLocation,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
    required this.status,
    this.alasanIzin,
    this.createdAt,
    this.updatedAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);
    // Parse alternate API fields
    map['attendance_date'] ??= map['date'] ?? '';
    map['check_in_time'] ??= map['check_in'];
    map['check_out_time'] ??= map['check_out'];

    // Support string coord types if returned by backend
    if (map['check_in_lat'] is String) {
      map['check_in_lat'] = double.tryParse(map['check_in_lat'] as String);
    }
    if (map['check_in_lng'] is String) {
      map['check_in_lng'] = double.tryParse(map['check_in_lng'] as String);
    }
    if (map['check_out_lat'] is String) {
      map['check_out_lat'] = double.tryParse(map['check_out_lat'] as String);
    }
    if (map['check_out_lng'] is String) {
      map['check_out_lng'] = double.tryParse(map['check_out_lng'] as String);
    }
    if (map['id'] is String) {
      map['id'] = int.tryParse(map['id'] as String) ?? 0;
    }
    if (map['user_id'] is String) {
      map['user_id'] = int.tryParse(map['user_id'] as String);
    }

    return _$AttendanceModelFromJson(map);
  }

  Map<String, dynamic> toJson() => _$AttendanceModelToJson(this);

  bool get isIzin => status.toLowerCase() == 'izin';
  bool get isMasuk => status.toLowerCase() == 'masuk';
  bool get hasCheckOut => checkOutTime != null && checkOutTime!.isNotEmpty;

  /// Batas masuk tepat waktu di PPKD adalah pukul 08:00:00 WIB
  bool get isLate {
    if (!isMasuk || checkInTime == null || checkInTime!.isEmpty) return false;
    final cleaned = checkInTime!.replaceAll(RegExp(r'[^0-9:]'), '');
    final parts = cleaned.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      return (hour > 8) || (hour == 8 && minute > 0);
    }
    return false;
  }

  bool get isOnTime => isMasuk && !isLate;
}

@JsonSerializable(explicitToJson: true)
class AttendanceTodayResponse {
  final String? message;
  final AttendanceModel? data;

  AttendanceTodayResponse({this.message, this.data});

  factory AttendanceTodayResponse.fromJson(Map<String, dynamic> json) =>
      _$AttendanceTodayResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceTodayResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AttendanceHistoryResponse {
  final String? message;
  @JsonKey(defaultValue: [])
  final List<AttendanceModel> data;

  AttendanceHistoryResponse({this.message, required this.data});

  factory AttendanceHistoryResponse.fromJson(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);
    if (map['data'] == null) {
      map['data'] = <Map<String, dynamic>>[];
    }
    return _$AttendanceHistoryResponseFromJson(map);
  }

  Map<String, dynamic> toJson() => _$AttendanceHistoryResponseToJson(this);
}
