import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'auth_model.g.dart';

@JsonSerializable(explicitToJson: true)
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RegisterRequest {
  final String name;
  final String email;
  final String password;
  @JsonKey(name: 'jenis_kelamin')
  final String jenisKelamin; // 'L' atau 'P'
  @JsonKey(name: 'batch_id')
  final int batchId;
  @JsonKey(name: 'training_id')
  final int trainingId;
  @JsonKey(name: 'profile_photo')
  final String? profilePhoto;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.jenisKelamin,
    required this.batchId,
    required this.trainingId,
    this.profilePhoto,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() {
    final map = _$RegisterRequestToJson(this);
    if (profilePhoto == null || profilePhoto!.isEmpty) {
      map.remove('profile_photo');
    }
    return map;
  }
}

@JsonSerializable(explicitToJson: true)
class AuthData {
  final String? token;
  final UserModel? user;

  AuthData({this.token, this.user});

  factory AuthData.fromJson(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);
    if (map['user'] is Map) {
      map['user'] = Map<String, dynamic>.from(map['user'] as Map);
    }
    return _$AuthDataFromJson(map);
  }

  Map<String, dynamic> toJson() => _$AuthDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AuthResponse {
  final String? message;
  final String? token;
  final UserModel? user;
  final AuthData? data;

  AuthResponse({
    this.message,
    this.token,
    this.user,
    this.data,
  });

  /// Token resolver: prioritaskan token langsung, fallback ke data.token
  String? get resolvedToken {
    if (token != null && token!.trim().isNotEmpty) return token!.trim();
    if (data?.token != null && data!.token!.trim().isNotEmpty) return data!.token!.trim();
    return null;
  }

  /// User resolver: prioritaskan user langsung, fallback ke data.user
  UserModel? get resolvedUser => user ?? data?.user;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final map = <String, dynamic>{};
    json.forEach((k, v) {
      if (k == 'data' && v is Map) {
        map['data'] = Map<String, dynamic>.from(v);
      } else if (k == 'user' && v is Map) {
        map['user'] = Map<String, dynamic>.from(v);
      } else {
        map[k] = v;
      }
    });

    if (map['data'] is Map) {
      final d = map['data'] as Map;
      if (map['token'] == null || map['token'].toString().isEmpty) {
        map['token'] = d['token']?.toString();
      }
      if (map['user'] == null && d['user'] is Map) {
        map['user'] = Map<String, dynamic>.from(d['user'] as Map);
      }
    }
    return _$AuthResponseFromJson(map);
  }

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ProfileResponse {
  final String? message;
  final UserModel? data;

  ProfileResponse({this.message, this.data});

  UserModel? get user => data;

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);
    if (map['data'] is Map<String, dynamic>) {
      // standard
    } else if (map['user'] is Map<String, dynamic>) {
      map['data'] = map['user'];
    }
    return _$ProfileResponseFromJson(map);
  }

  Map<String, dynamic> toJson() => _$ProfileResponseToJson(this);
}
