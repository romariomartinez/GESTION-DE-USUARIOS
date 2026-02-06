import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_usuarios/domain/entities/address.dart';

void main() {
  group('Address', () {
    const testAddress = Address(
      id: 'addr-1',
      userId: 'user-1',
      street: 'Calle 123',
      neighborhood: 'Centro',
      city: 'Bogotá',
      state: 'Cundinamarca',
      postalCode: '11001',
      label: 'Casa',
      isPrimary: true,
    );

    group('copyWith', () {
      test('actualiza street correctamente', () {
        final updated = testAddress.copyWith(street: 'Calle 456');

        expect(updated.street, 'Calle 456');
        expect(updated.id, testAddress.id);
        expect(updated.userId, testAddress.userId);
      });

      test('actualiza isPrimary correctamente', () {
        final updated = testAddress.copyWith(isPrimary: false);

        expect(updated.isPrimary, false);
        expect(testAddress.isPrimary, true);
      });

      test('preserva valores no actualizados', () {
        final updated = testAddress.copyWith(city: 'Medellín');

        expect(updated.city, 'Medellín');
        expect(updated.street, testAddress.street);
        expect(updated.neighborhood, testAddress.neighborhood);
        expect(updated.state, testAddress.state);
        expect(updated.postalCode, testAddress.postalCode);
        expect(updated.label, testAddress.label);
      });

      test('permite actualizar múltiples campos', () {
        final updated = testAddress.copyWith(
          city: 'Medellín',
          state: 'Antioquia',
          postalCode: '050001',
        );

        expect(updated.city, 'Medellín');
        expect(updated.state, 'Antioquia');
        expect(updated.postalCode, '050001');
      });
    });

    group('etiqueta personalizada', () {
      test('maneja etiqueta "Otro" correctamente', () {
        const otherAddress = Address(
          id: 'addr-2',
          userId: 'user-1',
          street: 'Calle 789',
          neighborhood: 'Barrio',
          city: 'Cali',
          state: 'Valle',
          postalCode: '760001',
          label: 'Otro',
          isPrimary: false,
        );

        expect(otherAddress.label, 'Otro');
      });

      test('diferencia entre etiquetas', () {
        const casa = Address(
          id: 'addr-1',
          userId: 'user-1',
          street: 'Calle 1',
          neighborhood: 'Centro',
          city: 'Bogotá',
          state: 'Cundinamarca',
          postalCode: '11001',
          label: 'Casa',
          isPrimary: true,
        );

        const trabajo = Address(
          id: 'addr-2',
          userId: 'user-1',
          street: 'Calle 2',
          neighborhood: 'Negocio',
          city: 'Bogotá',
          state: 'Cundinamarca',
          postalCode: '11001',
          label: 'Trabajo',
          isPrimary: false,
        );

        expect(casa.label, 'Casa');
        expect(trabajo.label, 'Trabajo');
        expect(casa.isPrimary, true);
        expect(trabajo.isPrimary, false);
      });
    });

    group('dirección principal única', () {
      test('solo una dirección puede ser primaria', () {
        const primary = Address(
          id: 'addr-primary',
          userId: 'user-1',
          street: 'Calle Principal',
          neighborhood: 'Centro',
          city: 'Bogotá',
          state: 'Cundinamarca',
          postalCode: '11001',
          label: 'Principal',
          isPrimary: true,
        );

        const secondary = Address(
          id: 'addr-secondary',
          userId: 'user-1',
          street: 'Calle Secundaria',
          neighborhood: 'Barrio',
          city: 'Bogotá',
          state: 'Cundinamarca',
          postalCode: '11001',
          label: 'Secundaria',
          isPrimary: false,
        );

        expect(primary.isPrimary, true);
        expect(secondary.isPrimary, false);
      });
    });
  });
}
