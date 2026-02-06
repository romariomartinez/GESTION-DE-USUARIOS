import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_usuarios/data/models/user_model.dart';
import 'package:gestion_usuarios/domain/entities/user.dart';

void main() {
  group('UserModel', () {
    final now = DateTime.now();
    final testUser = User(
      id: 'test-id-123',
      firstName: 'Juan',
      lastName: 'Pérez',
      birthDate: DateTime(now.year - 25, now.month, now.day),
      email: 'juan@test.com',
      phone: '+573001234567',
      addresses: const [],
    );

    group('fromEntity', () {
      test('convierte User a UserModel correctamente', () {
        final model = UserModel.fromEntity(testUser);

        expect(model.id, testUser.id);
        expect(model.firstName, testUser.firstName);
        expect(model.lastName, testUser.lastName);
        expect(model.birthDate, testUser.birthDate);
        expect(model.email, testUser.email);
        expect(model.phone, testUser.phone);
      });

      test('preserva todos los datos del User', () {
        final model = UserModel.fromEntity(testUser);

        expect(model.id, equals(testUser.id));
        expect(model.firstName, equals(testUser.firstName));
        expect(model.lastName, equals(testUser.lastName));
      });
    });

    group('toEntity', () {
      test('convierte UserModel a User correctamente', () {
        final model = UserModel(
          id: 'model-id-456',
          firstName: 'María',
          lastName: 'García',
          birthDate: DateTime(now.year - 30, 5, 15),
          email: 'maria@test.com',
          phone: '+573009998877',
        );

        final entity = model.toEntity();

        expect(entity.id, model.id);
        expect(entity.firstName, model.firstName);
        expect(entity.lastName, model.lastName);
        expect(entity.birthDate, model.birthDate);
        expect(entity.email, model.email);
        expect(entity.phone, model.phone);
      });

      test('roundtrip: fromEntity -> toEntity preserva datos', () {
        final originalUser = User(
          id: 'roundtrip-id',
          firstName: 'Carlos',
          lastName: 'López',
          birthDate: DateTime(1990, 10, 20),
          email: 'carlos@test.co',
          phone: '+57300111222',
          addresses: const [],
        );

        final model = UserModel.fromEntity(originalUser);
        final result = model.toEntity();

        expect(result.id, originalUser.id);
        expect(result.firstName, originalUser.firstName);
        expect(result.lastName, originalUser.lastName);
        expect(result.birthDate, originalUser.birthDate);
        expect(result.email, originalUser.email);
        expect(result.phone, originalUser.phone);
      });
    });
  });
}
