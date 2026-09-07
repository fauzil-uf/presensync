// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceModel _$AttendanceModelFromJson(Map<String, dynamic> json) =>
    AttendanceModel(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num?)?.toInt(),
      attendanceDate: json['attendance_date'] as String,
      checkInTime: json['check_in_time'] as String?,
      checkOutTime: json['check_out_time'] as String?,
      checkInAddress: json['check_in_address'] as String?,
      checkOutAddress: json['check_out_address'] as String?,
      checkInLocation: json['check_in_location'] as String?,
      checkOutLocation: json['check_out_location'] as String?,
      checkInLat: (json['check_in_lat'] as num?)?.toDouble(),
      checkInLng: (json['check_in_lng'] as num?)?.toDouble(),
      checkOutLat: (json['check_out_lat'] as num?)?.toDouble(),
      checkOutLng: (json['check_out_lng'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'masuk',
      alasanIzin: json['alasan_izin'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$AttendanceModelToJson(AttendanceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'attendance_date': instance.attendanceDate,
      'check_in_time': instance.checkInTime,
      'check_out_time': instance.checkOutTime,
      'check_in_address': instance.checkInAddress,
      'check_out_address': instance.checkOutAddress,
      'check_in_location': instance.checkInLocation,
      'check_out_location': instance.checkOutLocation,
      'check_in_lat': instance.checkInLat,
      'check_in_lng': instance.checkInLng,
      'check_out_lat': instance.checkOutLat,
      'check_out_lng': instance.checkOutLng,
      'status': instance.status,
      'alasan_izin': instance.alasanIzin,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

AttendanceTodayResponse _$AttendanceTodayResponseFromJson(
  Map<String, dynamic> json,
) => AttendanceTodayResponse(
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : AttendanceModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AttendanceTodayResponseToJson(
  AttendanceTodayResponse instance,
) => <String, dynamic>{
  'message': instance.message,
  'data': instance.data?.toJson(),
};

AttendanceHistoryResponse _$AttendanceHistoryResponseFromJson(
  Map<String, dynamic> json,
) => AttendanceHistoryResponse(
  message: json['message'] as String?,
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$AttendanceHistoryResponseToJson(
  AttendanceHistoryResponse instance,
) => <String, dynamic>{
  'message': instance.message,
  'data': instance.data.map((e) => e.toJson()).toList(),
};
