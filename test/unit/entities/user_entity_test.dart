import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_usuarios/domain/entities/address.dart';
import 'package:gestion_usuarios/domain/entities/user.dart';

void main() {
  group('User', () {
    final now = DateTime.now();

    User createTestUser({
      String id = 'test-id',
      String firstName = 'Juan',
      String lastName = 'Pérez',
      DateTime? birthDate,
      String email = 'juan@test.com',
      String phone = '+573001234567',
      List<Address> addresses = const [],
    }) {
      return User(
        id: id,
        firstName: firstName,
        lastName: lastName,
        birthDate: birthDate ?? DateTime(now.year - 25, now.month, now.day),
        email: email,
        phone: phone,
        addresses: addresses,
      );
    }

    group('fullName', () {
      test('retorna nombre y apellido concatenados', () {
        final user = createTestUser(firstName: 'Juan', lastName: 'Pérez');
        expect(user.fullName, 'Juan Pérez');
      });

      test('maneja nombres con tildes', () {
        final user = createTestUser(firstName: 'José', lastName: 'García');
        expect(user.fullName, 'José García');
      });

      test('maneja nombres compuestos', () {
        final user = createTestUser(firstName: 'María', lastName: 'Fernández');
        expect(user.fullName, 'María Fernández');
      });
    });

    group('primaryAddress', () {
      test('retorna null cuando no hay direcciones', () {
        final user = createTestUser(addresses: []);
        expect(user.primaryAddress, isNull);
      });

      test('retorna null cuando ninguna dirección es primaria', () {
        final addresses = [
          const Address(
            id: 'addr-1',
            userId: 'test-id',
            street: 'Calle 1',
            neighborhood: 'Barrio 1',
            city: 'Ciudad 1',
            state: 'Estado 1',
            postalCode: '12345',
            label: 'Casa',
            isPrimary: false,
          ),
        ];
        final user = createTestUser(addresses: addresses);
        expect(user.primaryAddress, isNull);
      });

      test('retorna dirección cuando es primaria', () {
        const primaryAddress = Address(
          id: 'addr-primary',
          userId: 'test-id',
          street: 'Calle Principal',
          neighborhood: 'Centro',
          city: 'Bogotá',
          state: 'Cundinamarca',
          postalCode: '11001',
          label: 'Principal',
          isPrimary: true,
        );
        final user = createTestUser(addresses: [primaryAddress]);
        expect(user.primaryAddress, equals(primaryAddress));
      });

      test('retorna primera dirección primaria cuando hay múltiples', () {
        const primaryAddress1 = Address(
          id: 'addr-1',
          userId: 'test-id',
          street: 'Calle 1',
          neighborhood: 'Barrio 1',
          city: 'Ciudad 1',
          state: 'Estado 1',
          postalCode: '12345',
          label: 'Principal',
          isPrimary: true,
        );
        const primaryAddress2 = Address(
          id: 'addr-2',
          userId: 'test-id',
          street: 'Calle 2',
          neighborhood: 'Barrio 2',
          city: 'Ciudad 2',
          state: 'Estado 2',
          postalCode: '67890',
          label: 'Otra',
          isPrimary: true,
        );
        final user = createTestUser(
          addresses: [primaryAddress2, primaryAddress1],
        );
        expect(user.primaryAddress?.id, 'addr-2');
      });
    });

    group('primaryCity', () {
      test('retorna null cuando no hay dirección primaria', () {
        final user = createTestUser(addresses: []);
        expect(user.primaryCity, isNull);
      });

      test('retorna ciudad de dirección primaria', () {
        const address = Address(
          id: 'addr-1',
          userId: 'test-id',
          street: 'Calle 1',
          neighborhood: 'Centro',
          city: 'Medellín',
          state: 'Antioquia',
          postalCode: '050001',
          label: 'Casa',
          isPrimary: true,
        );
        final user = createTestUser(addresses: [address]);
        expect(user.primaryCity, 'Medellín');
      });
    });

    group('age', () {
      test('calcula edad correctamente', () {
        final birthDate = DateTime(now.year - 25, now.month, now.day);
        final user = createTestUser(birthDate: birthDate);
        expect(user.age, 25);
      });

      test('considera si ya pasó el cumpleaños', () {
        final birthDate = DateTime(now.year - 26, now.month - 1, now.day);
        final user = createTestUser(birthDate: birthDate);
        expect(user.age, greaterThanOrEqualTo(24));
      });
    });
  });
}
