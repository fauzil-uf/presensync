import 'package:flutter_test/flutter_test.dart';
import 'package:presensync/models/auth_model.dart';
import 'package:presensync/models/user_model.dart';
import 'package:presensync/services/auth_storage.dart';
import 'package:presensync/views/auth/login_screen.dart';
import 'package:presensync/views/dashboard/main_navigation_screen.dart';
import 'package:presensync/views/splash/splash_screen.dart';
import 'package:presensync/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AuthStorage.clearSession();
  });

  group('Persistent Auto-Login & Session Tests', () {
    test('resolvedToken properly retrieves token from nested data structure', () {
      final json = {
        'message': 'Login berhasil',
        'data': {
          'token': '12345|jwt_token_example',
          'user': {
            'id': 10,
            'name': 'Budi Santoso',
            'email': 'budi@gmail.com',
          }
        }
      };

      final response = AuthResponse.fromJson(json);
      expect(response.resolvedToken, '12345|jwt_token_example');
      expect(response.resolvedUser?.name, 'Budi Santoso');
    });

    testWidgets('App displays SplashScreen on startup and navigates to MainNavigationScreen when authenticated',
        (WidgetTester tester) async {
      await AuthStorage.saveSession(
        token: '12345|valid_token',
        user: UserModel(
          id: 10,
          name: 'Budi Santoso',
          email: 'budi@gmail.com',
        ),
      );

      expect(AuthStorage.token, '12345|valid_token');

      await tester.pumpWidget(const AbsensiApp());
      await tester.pump();

      // SplashScreen should be present immediately
      expect(find.byType(SplashScreen), findsOneWidget);

      // Settle splash delay and transition
      await tester.pump(const Duration(milliseconds: 2600));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(MainNavigationScreen), findsOneWidget);
    });

    testWidgets('App launches to SplashScreen and transitions to LoginScreen when unauthenticated',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await AuthStorage.init();
      expect(AuthStorage.token, isNull);

      await tester.pumpWidget(const AbsensiApp());
      await tester.pump();

      // SplashScreen should be present
      expect(find.byType(SplashScreen), findsOneWidget);

      // Settle splash timer and transition
      await tester.pump(const Duration(milliseconds: 2600));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
