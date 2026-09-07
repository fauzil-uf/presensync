import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel {
  final int id;
  final String name;
  final String email;
  @JsonKey(name: 'email_verified_at')
  final String? emailVerifiedAt;
  final String? role;
  @JsonKey(name: 'is_active')
  final dynamic isActive;
  @JsonKey(name: 'batch_id')
  final int? batchId;
  @JsonKey(name: 'training_id')
  final int? trainingId;
  @JsonKey(name: 'batch_ke')
  final dynamic batchKe;
  @JsonKey(name: 'training_title')
  final String? trainingTitle;
  final TrainingModel? training;
  final BatchModel? batch;
  @JsonKey(name: 'jenis_kelamin')
  final String? jenisKelamin;
  @JsonKey(name: 'profile_photo')
  final String? profilePhoto;
  @JsonKey(name: 'profile_photo_url')
  final String? profilePhotoUrl;
  @JsonKey(name: 'onesignal_player_id')
  final String? onesignalPlayerId;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.role,
    this.isActive,
    this.batchId,
    this.trainingId,
    this.batchKe,
    this.trainingTitle,
    this.training,
    this.batch,
    this.jenisKelamin,
    this.profilePhoto,
    this.profilePhotoUrl,
    this.onesignalPlayerId,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);

    // Fallback batch_id if missing or null, extract from batch relation
    if (!map.containsKey('batch_id') || map['batch_id'] == null) {
      if (map['batch'] is Map<String, dynamic>) {
        map['batch_id'] = map['batch']['id'];
      }
    }
    if (map['batch_id'] is String) {
      map['batch_id'] = int.tryParse(map['batch_id'] as String);
    }

    // Fallback training_id if missing or null, extract from training relation
    if (!map.containsKey('training_id') || map['training_id'] == null) {
      if (map['training'] is Map<String, dynamic>) {
        map['training_id'] = map['training']['id'];
      }
    }
    if (map['training_id'] is String) {
      map['training_id'] = int.tryParse(map['training_id'] as String);
    }

    // Fallback training_title if missing
    if (!map.containsKey('training_title') || map['training_title'] == null) {
      if (map['training'] is Map<String, dynamic>) {
        map['training_title'] = map['training']['title'] ?? map['training']['name'];
      }
    }

    // Fallback batch_ke if missing
    if (!map.containsKey('batch_ke') || map['batch_ke'] == null) {
      if (map['batch'] is Map<String, dynamic>) {
        map['batch_ke'] = map['batch']['batch_ke'];
      }
    }

    // Tangani created_at:
    // PENTING: Jangan gunakan map['batch']['created_at'] sebagai tanggal terdaftar user!
    // Karena map['batch']['created_at'] adalah tanggal saat angkatan/batch dibuat oleh admin PPKD (misal: 02 April 2026).
    // Jika created_at user kosong atau keliru terisi tanggal batch, gunakan tanggal hari ini / waktu registrasi riil.
    String? batchCreatedAt;
    if (map['batch'] is Map<String, dynamic>) {
      batchCreatedAt = map['batch']['created_at']?.toString();
    }

    final rawCreatedAt = map['created_at']?.toString();
    if (rawCreatedAt == null ||
        rawCreatedAt.isEmpty ||
        (batchCreatedAt != null && rawCreatedAt == batchCreatedAt)) {
      map['created_at'] = DateTime.now().toIso8601String();
    }

    return _$UserModelFromJson(map);
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  String get avatarLetter {
    if (name.isNotEmpty) {
      return name[0].toUpperCase();
    }
    return 'U';
  }

  String get displayTraining {
    if (trainingTitle != null && trainingTitle!.isNotEmpty) {
      return trainingTitle!;
    }
    if (training != null && training!.title.isNotEmpty) {
      return training!.title;
    }
    if (trainingId != null) {
      return 'Kejuruan #$trainingId';
    }
    return '-';
  }

  String get displayBatch {
    if (batchKe != null) {
      return 'Batch $batchKe';
    }
    if (batch != null && batch!.batchName.isNotEmpty) {
      return batch!.batchName;
    }
    if (batchId != null) {
      return 'Batch $batchId';
    }
    return '-';
  }

  String? get fullProfilePhotoUrl {
    if (profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty) {
      return profilePhotoUrl;
    }
    if (profilePhoto == null || profilePhoto!.isEmpty) return null;
    if (profilePhoto!.startsWith('http://') ||
        profilePhoto!.startsWith('https://')) {
      return profilePhoto;
    }
    return 'https://appabsensi.mobileprojp.com/storage/$profilePhoto';
  }
}

typedef User = UserModel;

@JsonSerializable(explicitToJson: true)
class TrainingModel {
  final int id;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(name: 'batch_id')
  final int? batchId;

  TrainingModel({
    required this.id,
    required this.title,
    this.batchId,
  });

  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);
    if (!map.containsKey('title') && map.containsKey('name')) {
      map['title'] = map['name'];
    }
    if (map['id'] is String) {
      map['id'] = int.tryParse(map['id'] as String) ?? 0;
    }
    return _$TrainingModelFromJson(map);
  }

  Map<String, dynamic> toJson() => _$TrainingModelToJson(this);
}

typedef Training = TrainingModel;

@JsonSerializable(explicitToJson: true)
class BatchModel {
  final int id;
  @JsonKey(name: 'batch_name', defaultValue: '')
  final String batchName;
  @JsonKey(name: 'batch_ke')
  final dynamic batchKe;
  final String? year;
  @JsonKey(name: 'start_date')
  final String? startDate;
  @JsonKey(name: 'end_date')
  final String? endDate;

  BatchModel({
    required this.id,
    required this.batchName,
    this.batchKe,
    this.year,
    this.startDate,
    this.endDate,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);
    if (!map.containsKey('batch_name')) {
      if (map['batch_ke'] != null) {
        map['batch_name'] = 'Batch ${map['batch_ke']}';
      } else {
        map['batch_name'] = map['name'] ?? map['batch'] ?? 'Batch ${map['id']}';
      }
    }
    if (map['id'] is String) {
      map['id'] = int.tryParse(map['id'] as String) ?? 0;
    }
    return _$BatchModelFromJson(map);
  }

  Map<String, dynamic> toJson() => _$BatchModelToJson(this);
}

typedef Batch = BatchModel;
