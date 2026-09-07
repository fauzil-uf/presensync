// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String,
  emailVerifiedAt: json['email_verified_at'] as String?,
  role: json['role'] as String?,
  isActive: json['is_active'],
  batchId: (json['batch_id'] as num?)?.toInt(),
  trainingId: (json['training_id'] as num?)?.toInt(),
  batchKe: json['batch_ke'],
  trainingTitle: json['training_title'] as String?,
  training: json['training'] == null
      ? null
      : TrainingModel.fromJson(json['training'] as Map<String, dynamic>),
  batch: json['batch'] == null
      ? null
      : BatchModel.fromJson(json['batch'] as Map<String, dynamic>),
  jenisKelamin: json['jenis_kelamin'] as String?,
  profilePhoto: json['profile_photo'] as String?,
  profilePhotoUrl: json['profile_photo_url'] as String?,
  onesignalPlayerId: json['onesignal_player_id'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'email_verified_at': instance.emailVerifiedAt,
  'role': instance.role,
  'is_active': instance.isActive,
  'batch_id': instance.batchId,
  'training_id': instance.trainingId,
  'batch_ke': instance.batchKe,
  'training_title': instance.trainingTitle,
  'training': instance.training?.toJson(),
  'batch': instance.batch?.toJson(),
  'jenis_kelamin': instance.jenisKelamin,
  'profile_photo': instance.profilePhoto,
  'profile_photo_url': instance.profilePhotoUrl,
  'onesignal_player_id': instance.onesignalPlayerId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

TrainingModel _$TrainingModelFromJson(Map<String, dynamic> json) =>
    TrainingModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      batchId: (json['batch_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TrainingModelToJson(TrainingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'batch_id': instance.batchId,
    };

BatchModel _$BatchModelFromJson(Map<String, dynamic> json) => BatchModel(
  id: (json['id'] as num).toInt(),
  batchName: json['batch_name'] as String? ?? '',
  batchKe: json['batch_ke'],
  year: json['year'] as String?,
  startDate: json['start_date'] as String?,
  endDate: json['end_date'] as String?,
);

Map<String, dynamic> _$BatchModelToJson(BatchModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'batch_name': instance.batchName,
      'batch_ke': instance.batchKe,
      'year': instance.year,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
    };
