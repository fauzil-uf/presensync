import 'package:dio/dio.dart';
import '../models/auth_model.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'auth_storage.dart';
import 'dio_client.dart';

class AuthService {
  final Dio _dio;
  final ApiService api;

  Dio get dio => _dio;

  AuthService({Dio? dio, ApiService? api})
      : _dio = dio ?? DioClient.createDio(),
        api = api ?? ApiService(dio ?? DioClient.createDio());

  factory AuthService.create() {
    final dio = DioClient.createDio();
    return AuthService(dio: dio, api: ApiService(dio));
  }

  // 1. Login User
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final authResponse = await api.login(request.toJson());
      final token = authResponse.resolvedToken;
      final user = authResponse.resolvedUser;

      if (token != null && token.isNotEmpty) {
        await AuthStorage.saveSession(
          token: token,
          user: user,
        );
      }
      return authResponse;
    } catch (e) {
      throw Exception(DioClient.parseErrorMessage(e));
    }
  }

  // 2. Register User
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final authResponse = await api.register(request.toJson());
      final token = authResponse.resolvedToken;
      final user = authResponse.resolvedUser;

      if (token != null && token.isNotEmpty) {
        await AuthStorage.saveSession(
          token: token,
          user: user,
        );
        return authResponse;
      } else {
        // Auto-login jika API registrasi tidak mengembalikan token
        final loginResponse = await login(
          LoginRequest(email: request.email, password: request.password),
        );
        return loginResponse;
      }
    } catch (e) {
      throw Exception(DioClient.parseErrorMessage(e));
    }
  }

  // 3. Ambil Profile Pengguna
  Future<User?> getProfile() async {
    try {
      final token = await AuthStorage.getToken();
      if (token != null && token.isNotEmpty) {
        final profileResp = await api.getProfile('Bearer $token');
        if (profileResp.user != null) {
          await AuthStorage.saveUser(profileResp.user!);
        }
        return profileResp.user;
      }
      return null;
    } catch (e) {
      throw Exception(DioClient.parseErrorMessage(e));
    }
  }

  // 4. Update Profile (Nama / Email)
  Future<User?> updateProfile({required String name, String? email}) async {
    try {
      final token = await AuthStorage.getToken();
      final body = <String, dynamic>{'name': name};
      if (email != null && email.isNotEmpty) {
        body['email'] = email;
      }

      final profileResp = await api.updateProfile(
        token != null ? 'Bearer $token' : '',
        body,
      );

      if (profileResp.user != null) {
        await AuthStorage.saveUser(profileResp.user!);
      }
      return profileResp.user;
    } catch (e) {
      throw Exception(DioClient.parseErrorMessage(e));
    }
  }

  // 5. Update Profile Photo
  Future<String?> updateProfilePhoto(String base64Image) async {
    try {
      final token = await AuthStorage.getToken();
      final resp = await api.updateProfilePhoto(
        token != null ? 'Bearer $token' : '',
        {'profile_photo': base64Image},
      );

      final message = resp is Map ? resp['message']?.toString() : null;
      await getProfile();
      return message ?? 'Foto profil berhasil diperbarui';
    } catch (e) {
      throw Exception(DioClient.parseErrorMessage(e));
    }
  }

  // 6. Get Trainings List
  Future<List<Training>> getTrainings() async {
    try {
      final resp = await api.getTrainings();
      final list = <Training>[];
      if (resp is Map && resp['data'] is List) {
        for (final item in resp['data'] as List) {
          if (item is Map<String, dynamic>) {
            list.add(Training.fromJson(item));
          }
        }
      }
      return list;
    } catch (_) {
      return [
        Training(id: 1, title: 'Flutter Mobile App Developer'),
        Training(id: 16, title: 'Junior Mobile Programmer'),
        Training(id: 14, title: 'Web Developer'),
      ];
    }
  }

  // 7. Get Batches List
  Future<List<Batch>> getBatches() async {
    try {
      final resp = await api.getBatches();
      final list = <Batch>[];
      if (resp is Map && resp['data'] is List) {
        for (final item in resp['data'] as List) {
          if (item is Map<String, dynamic>) {
            list.add(Batch.fromJson(item));
          }
        }
      }
      return list;
    } catch (_) {
      return [
        Batch(id: 1, batchName: 'Batch 1 - 2026'),
        Batch(id: 2, batchName: 'Batch 2 - 2026'),
        Batch(id: 7, batchName: 'Batch 7 - 2026'),
      ];
    }
  }

  // 8. Logout
  Future<void> logout() async {
    await AuthStorage.clearSession();
  }
}
