import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/auth_model.dart';


part 'api_service.g.dart';

@RestApi(baseUrl: 'https://appabsensi.mobileprojp.com/api')
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @POST('/register')
  Future<AuthResponse> register(@Body() Map<String, dynamic> body);

  @POST('/login')
  Future<AuthResponse> login(@Body() Map<String, dynamic> body);

  @GET('/profile')
  Future<ProfileResponse> getProfile(@Header('Authorization') String token);

  @PUT('/profile')
  Future<ProfileResponse> updateProfile(
    @Header('Authorization') String token,
    @Body() Map<String, dynamic> body,
  );

  @PUT('/profile/photo')
  Future<dynamic> updateProfilePhoto(
    @Header('Authorization') String token,
    @Body() Map<String, dynamic> body,
  );

  @GET('/batches')
  Future<dynamic> getBatches();

  @GET('/trainings')
  Future<dynamic> getTrainings();

  @POST('/absen/check-in')
  Future<dynamic> checkIn(
    @Header('Authorization') String token,
    @Body() Map<String, dynamic> body,
  );

  @POST('/absen/check-out')
  Future<dynamic> checkOut(
    @Header('Authorization') String token,
    @Body() Map<String, dynamic> body,
  );

  @POST('/izin')
  Future<dynamic> submitLeave(
    @Header('Authorization') String token,
    @Body() Map<String, dynamic> body,
  );

  @GET('/absen/today')
  Future<dynamic> getTodayAttendance(
    @Header('Authorization') String token,
    @Query('attendance_date') String attendanceDate,
  );

  @GET('/absen/stats')
  Future<dynamic> getAttendanceStats(
    @Header('Authorization') String token,
    @Query('year') String? year,
    @Query('start') String? start,
    @Query('end') String? end,
  );

  @GET('/absen/history')
  Future<dynamic> getAttendanceHistory(
    @Header('Authorization') String token,
  );

  @DELETE('/absen/{id}')
  Future<dynamic> deleteAttendance(
    @Header('Authorization') String token,
    @Path('id') int id,
  );

  @POST('/device-token')
  Future<dynamic> saveDeviceToken(
    @Header('Authorization') String token,
    @Body() Map<String, dynamic> body,
  );
}
