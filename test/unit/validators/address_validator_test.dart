import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_usuarios/core/validators/address_validator.dart';

void main() {
  group('validateStreet', () {
    test('retorna error cuando street está vacío', () {
      final result = validateStreet('');
      expect(result, isNotNull);
      expect(result, contains('obligatorios'));
    });

    test('retorna error cuando street solo tiene espacios', () {
      final result = validateStreet('   ');
      expect(result, isNotNull);
    });

    test('retorna null para street válido', () {
      final result = validateStreet('Calle Principal 123');
      expect(result, isNull);
    });

    test('retorna null para street con 3 caracteres exactos', () {
      final result = validateStreet('ABC');
      expect(result, isNull);
    });

    test('retorna error cuando street tiene menos de 3 caracteres', () {
      final result = validateStreet('AB');
      expect(result, isNotNull);
    });
  });

  group('validateNeighborhood', () {
    test('retorna null para neighborhood vacío (campo opcional)', () {
      final result = validateNeighborhood('');
      expect(result, isNull);
    });

    test('retorna null para neighborhood válido', () {
      final result = validateNeighborhood('Centro');
      expect(result, isNull);
    });

    test('retorna error cuando neighborhood tiene menos de 2 caracteres', () {
      final result = validateNeighborhood('A');
      expect(result, isNotNull);
    });
  });

  group('validateCity', () {
    test('retorna error cuando city está vacío', () {
      final result = validateCity('');
      expect(result, isNotNull);
      expect(result, contains('obligatoria'));
    });

    test('retorna null para city válido', () {
      final result = validateCity('Bogotá');
      expect(result, isNull);
    });

    test('retorna error cuando city tiene menos de 2 caracteres', () {
      final result = validateCity('A');
      expect(result, isNotNull);
    });
  });

  group('validateState', () {
    test('retorna error cuando state está vacío', () {
      final result = validateState('');
      expect(result, isNotNull);
      expect(result, contains('obligatorio'));
    });

    test('retorna null para state válido', () {
      final result = validateState('Cundinamarca');
      expect(result, isNull);
    });

    test('retorna error cuando state tiene menos de 2 caracteres', () {
      final result = validateState('A');
      expect(result, isNotNull);
    });
  });

  group('validatePostalCode', () {
    test('retorna error cuando postal code está vacío', () {
      final result = validatePostalCode('');
      expect(result, isNotNull);
      expect(result, contains('obligatorio'));
    });

    test('retorna null para postal code válido', () {
      final result = validatePostalCode('110111');
      expect(result, isNull);
    });

    test('retorna null para postal code con guión', () {
      final result = validatePostalCode('11011-1');
      expect(result, isNull);
    });

    test('retorna error cuando postal code tiene menos de 3 caracteres', () {
      final result = validatePostalCode('11');
      expect(result, isNotNull);
    });

    test('retorna error cuando postal code tiene más de 10 caracteres', () {
      final result = validatePostalCode('12345678901');
      expect(result, isNotNull);
    });

    test('retorna error cuando postal code tiene caracteres inválidos', () {
      final result = validatePostalCode('110@111');
      expect(result, isNotNull);
    });
  });
}
