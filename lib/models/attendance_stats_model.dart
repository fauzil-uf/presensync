import 'package:json_annotation/json_annotation.dart';

part 'attendance_stats_model.g.dart';

@JsonSerializable(explicitToJson: true)
class AttendanceStatsModel {
  @JsonKey(name: 'total_absen', defaultValue: 0)
  final int totalAbsen;
  @JsonKey(name: 'total_masuk', defaultValue: 0)
  final int totalMasuk;
  @JsonKey(name: 'total_izin', defaultValue: 0)
  final int totalIzin;
  @JsonKey(name: 'sudah_absen_hari_ini', defaultValue: false)
  final bool sudahAbsenHariIni;

  AttendanceStatsModel({
    required this.totalAbsen,
    required this.totalMasuk,
    required this.totalIzin,
    required this.sudahAbsenHariIni,
  });

  factory AttendanceStatsModel.fromJson(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);
    if (map['total_absen'] is String) {
      map['total_absen'] = int.tryParse(map['total_absen'] as String) ?? 0;
    }
    if (map['total_masuk'] is String) {
      map['total_masuk'] = int.tryParse(map['total_masuk'] as String) ?? 0;
    }
    if (map['total_izin'] is String) {
      map['total_izin'] = int.tryParse(map['total_izin'] as String) ?? 0;
    }
    if (map['sudah_absen_hari_ini'] is String) {
      map['sudah_absen_hari_ini'] =
          (map['sudah_absen_hari_ini'] as String).toLowerCase() == 'true' ||
              map['sudah_absen_hari_ini'] == '1';
    }
    return _$AttendanceStatsModelFromJson(map);
  }

  Map<String, dynamic> toJson() => _$AttendanceStatsModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AttendanceStatsResponse {
  final String? message;
  final AttendanceStatsModel? data;

  AttendanceStatsResponse({this.message, this.data});

  factory AttendanceStatsResponse.fromJson(Map<String, dynamic> json) =>
      _$AttendanceStatsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceStatsResponseToJson(this);
}
