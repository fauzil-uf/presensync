import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import 'auth_storage.dart';

/// Sinkronisasi waktu otomatis dengan Server Backend (mencegah bypass ubah jam di HP)
class ServerTimeSync {
  static Duration _serverOffset = Duration.zero;
  static bool hasSynced = false;

  static void syncFromHeader(String? dateHeader) {
    if (dateHeader == null || dateHeader.isEmpty) return;
    try {
      final serverTime = HttpDate.parse(dateHeader);
      final localUtc = DateTime.now().toUtc();
      _serverOffset = serverTime.difference(localUtc);
      hasSynced = true;
    } catch (_) {}
  }

  /// Waktu saat ini yang akurat & tersinkronisasi dengan server
  static DateTime get accurateNow {
    return DateTime.now().add(_serverOffset);
  }
}

class DioClient {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static void Function()? onSessionExpired;

  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptor to attach Bearer token & synchronize server time
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AuthStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final dateHeader = response.headers.value('date');
          if (dateHeader != null) {
            ServerTimeSync.syncFromHeader(dateHeader);
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          final dateHeader = error.response?.headers.value('date');
          if (dateHeader != null) {
            ServerTimeSync.syncFromHeader(dateHeader);
          }

          // Tangani 401 Unauthorized secara otomatis pada sesi yang kedaluwarsa
          if (error.response?.statusCode == 401) {
            final path = error.requestOptions.path;
            if (!path.contains('/login') && !path.contains('/register')) {
              await AuthStorage.clearSession();
              onSessionExpired?.call();
              navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
            }
          }

          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  // Clean error message parser from DioException
  static String parseErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data is Map<String, dynamic>) {
        final data = error.response!.data as Map<String, dynamic>;

        // Handle Laravel validation errors (errors: { field: [msg1, msg2] })
        if (data['errors'] is Map<String, dynamic>) {
          final errors = data['errors'] as Map<String, dynamic>;
          final errorMessages = <String>[];
          errors.forEach((key, value) {
            if (value is List) {
              errorMessages.addAll(value.map((e) => e.toString()));
            } else if (value != null) {
              errorMessages.add(value.toString());
            }
          });
          if (errorMessages.isNotEmpty) {
            return errorMessages.join('\n');
          }
        }

        if (data['message'] != null && data['message'].toString().isNotEmpty) {
          return data['message'].toString();
        }
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Waktu koneksi habis. Silakan periksa jaringan internet Anda.';
      }

      if (error.type == DioExceptionType.connectionError) {
        return 'Gagal terhubung ke server absensi. Periksa koneksi internet Anda.';
      }

      if (error.response?.statusCode == 401) {
        return 'Sesi login telah berakhir atau data tidak sah. Silakan login kembali.';
      }

      if (error.response?.statusCode == 404) {
        return 'Data tidak ditemukan di server.';
      }

      if (error.response?.statusCode == 409) {
        return 'Terjadi konflik data (Anda mungkin sudah absen hari ini).';
      }

      return error.message ?? 'Terjadi kesalahan pada sistem.';
    }

    return error.toString();
  }
}
