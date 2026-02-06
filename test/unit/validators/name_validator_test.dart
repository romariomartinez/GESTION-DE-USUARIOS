import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_usuarios/core/validators/name_validator.dart';

void main() {
  group('validateName', () {
    group('vacío', () {
      test('retorna error cuando el valor está vacío', () {
        expect(validateName(''), 'Este campo es obligatorio');
      });

      test('retorna error cuando el valor solo tiene espacios', () {
        expect(validateName('   '), 'Este campo es obligatorio');
      });

      test('retorna null para valor válido', () {
        expect(validateName('John'), isNull);
      });
    });

    group('longitud mínima', () {
      test('retorna error cuando tiene 1 caracter', () {
        expect(validateName('J'), 'Debe tener al menos 2 caracteres');
      });

      test('retorna null cuando tiene 2 caracteres', () {
        expect(validateName('Jo'), isNull);
      });

      test('retorna null cuando tiene 3 caracteres', () {
        expect(validateName('Joh'), isNull);
      });
    });

    group('longitud máxima', () {
      test('acepta nombre de 50 caracteres', () {
        final name = 'J' * 50;
        expect(validateName(name), isNull);
      });

      test('acepta nombre de 49 caracteres', () {
        final name = 'J' * 49;
        expect(validateName(name), isNull);
      });
    });

    group('caracteres válidos', () {
      test('acepta nombres con espacios', () {
        expect(validateName('Juan Carlos'), isNull);
      });

      test('acepta nombres con tildes', () {
        expect(validateName('José'), isNull);
      });

      test('acepta nombres con ñ', () {
        expect(validateName('año'), isNull);
      });

      test('acepta nombres con guiones', () {
        expect(validateName('Mary-Jane'), isNull);
      });

      test('acepta nombres con apóstrofes', () {
        expect(validateName("O'Connor"), isNull);
      });
    });
  });
}
