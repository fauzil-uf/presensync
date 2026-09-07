import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:presensync/models/auth_model.dart';
import 'package:presensync/services/auth_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Test AuthResponse parsing from real server register and login response', () async {
    SharedPreferences.setMockInitialValues({});
    
    // Exact register payload from server
    const regJson = '''
    {
      "message": "Registrasi berhasil",
      "data": {
        "token": "9562|real_token_123",
        "user": {
          "id": 1315,
          "name": "Tester Date",
          "email": "test@gmail.com",
          "batch_id": 1,
          "training_id": 16,
          "jenis_kelamin": "L"
        }
      }
    }
    ''';
    
    final map = jsonDecode(regJson) as Map<String, dynamic>;
    final resp = AuthResponse.fromJson(map);
    
    expect(resp.resolvedToken, '9562|real_token_123');
    expect(resp.token, '9562|real_token_123');
    expect(resp.data?.token, '9562|real_token_123');
    expect(resp.resolvedUser?.name, 'Tester Date');
    expect(resp.user?.name, 'Tester Date');
    
    // Now save session
    await AuthStorage.saveSession(token: resp.resolvedToken!, user: resp.resolvedUser);
    
    // Now test getToken()
    final token = await AuthStorage.getToken();
    expect(token, '9562|real_token_123');
    
    // Now simulate app restart: re-init AuthStorage
    await AuthStorage.init();
    expect(AuthStorage.token, '9562|real_token_123');
    expect(AuthStorage.currentUser?.name, 'Tester Date');
  });
}
