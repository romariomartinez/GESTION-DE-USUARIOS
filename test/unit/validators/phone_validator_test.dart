import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_usuarios/core/validators/phone_validator.dart';

void main() {
  group('PhoneValidator.validate', () {
    group('vacío', () {
      test('retorna error cuando el número está vacío', () {
        expect(
          PhoneValidator.validate(phoneNumber: '', isoCode: 'CO'),
          'El número de teléfono es requerido',
        );
      });
    });

    group('longitud', () {
      test('retorna error cuando tiene menos de 7 dígitos', () {
        expect(
          PhoneValidator.validate(phoneNumber: '123456', isoCode: 'CO'),
          'El número es muy corto',
        );
      });

      test('retorna error cuando tiene más de 15 dígitos', () {
        expect(
          PhoneValidator.validate(
            phoneNumber: '1234567890123456',
            isoCode: 'CO',
          ),
          'El número es muy largo',
        );
      });

      test('retorna null para 7 dígitos válidos', () {
        expect(
          PhoneValidator.validate(phoneNumber: '1234567', isoCode: 'CO'),
          isNull,
        );
      });

      test('retorna null para 15 dígitos válidos', () {
        expect(
          PhoneValidator.validate(
            phoneNumber: '123456789012345',
            isoCode: 'CO',
          ),
          isNull,
        );
      });
    });

    group('formato correcto', () {
      test('retorna null para número con guiones', () {
        expect(
          PhoneValidator.validate(phoneNumber: '300-123-4567', isoCode: 'CO'),
          isNull,
        );
      });

      test('retorna null para número con espacios', () {
        expect(
          PhoneValidator.validate(phoneNumber: '300 123 4567', isoCode: 'CO'),
          isNull,
        );
      });

      test('retorna null para número con paréntesis', () {
        expect(
          PhoneValidator.validate(phoneNumber: '(300) 123-4567', isoCode: 'CO'),
          isNull,
        );
      });
    });

    group('caracteres inválidos', () {
      test('retorna null para letras en el número (se limpian)', () {
        // El validador extrae solo dígitos
        expect(
          PhoneValidator.validate(phoneNumber: '3001234567abc', isoCode: 'CO'),
          isNull,
        );
      });
    });
  });

  group('PhoneValidator.toE164', () {
    test('convierte código y número a formato E.164', () {
      expect(PhoneValidator.toE164('+57', '3001234567'), '+573001234567');
    });

    test('limpia caracteres no numéricos', () {
      expect(PhoneValidator.toE164('+57', '300-123-4567'), '+573001234567');
    });

    test('maneja código largo', () {
      expect(PhoneValidator.toE164('+593', '987654321'), '+593987654321');
    });
  });
}
