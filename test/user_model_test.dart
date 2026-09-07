import 'package:flutter_test/flutter_test.dart';
import 'package:presensync/core/utils/date_formatter.dart';
import 'package:presensync/models/user_model.dart';

void main() {
  group('UserModel & Registration Date Tests', () {
    test('Does NOT fallback to Batch 5 creation date (02 April 2026)', () {
      final json = {
        'id': 100,
        'name': 'Fauzil',
        'email': 'fauzil@example.com',
        'batch_id': 4,
        'training_id': 16,
        'batch': {
          'id': 4,
          'batch_ke': 5,
          'created_at': '2026-04-02T03:43:01.000000Z',
        },
      };

      final user = User.fromJson(json);

      // User's registration date should NOT be 02 April 2026
      expect(user.createdAt, isNot('2026-04-02T03:43:01.000000Z'));
      
      final formatted = DateFormatter.formatFriendly(user.createdAt);
      expect(formatted, isNot(contains('02 April 2026')));
      expect(formatted, contains('September 2026'));
    });

    test('Preserves valid user created_at if provided', () {
      final json = {
        'id': 101,
        'name': 'Fauzil',
        'email': 'fauzil@example.com',
        'created_at': '2026-09-07T08:00:00.000000Z',
        'batch': {
          'id': 4,
          'batch_ke': 5,
          'created_at': '2026-04-02T03:43:01.000000Z',
        },
      };

      final user = User.fromJson(json);
      expect(user.createdAt, '2026-09-07T08:00:00.000000Z');
      expect(DateFormatter.formatFriendly(user.createdAt), 'Senin, 07 September 2026');
    });
  });
}
