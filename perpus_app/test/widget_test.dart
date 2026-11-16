import 'package:flutter_test/flutter_test.dart';
import 'package:perpus_app/models/user_model.dart';

void main() {
  group('UserModel Test', () {
    test('Berhasil membaca data pengguna dari JSON', () {
      final json = {
        'id': 1,
        'name': 'Fadli Hasan',
        'email': 'fadli@example.com',
        'created_at': '2026-11-10T10:00:00.000000Z',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 1);
      expect(user.name, 'Fadli Hasan');
      expect(user.email, 'fadli@example.com');
      expect(user.createdAt, isNotNull);
    });

    test('Tanggal bergabung null jika tidak tersedia', () {
      final json = {
        'id': 2,
        'name': 'Pengguna',
        'email': 'user@example.com',
        'created_at': null,
      };

      final user = UserModel.fromJson(json);

      expect(user.createdAt, isNull);
    });
  });
}
