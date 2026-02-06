import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_usuarios/core/validators/email_validator.dart';

void main() {
  group('validateEmail', () {
    group('vacío', () {
      test('retorna error cuando está vacío', () {
        expect(validateEmail(''), 'El email es obligatorio');
      });

      test('retorna error cuando solo tiene espacios', () {
        expect(validateEmail('   '), 'El email es obligatorio');
      });
    });

    group('formato inválido', () {
      test('retorna error para email sin @', () {
        expect(validateEmail('email.com'), 'Formato de email inválido');
      });

      test('retorna error para email sin dominio', () {
        expect(validateEmail('email@'), 'Formato de email inválido');
      });

      test('retorna error para email sin usuario', () {
        expect(validateEmail('@email.com'), 'Formato de email inválido');
      });

      test('retorna error para email con espacios', () {
        expect(validateEmail('email @email.com'), 'Formato de email inválido');
      });

      test('retorna error para email con múltiples @', () {
        expect(validateEmail('email@@email.com'), 'Formato de email inválido');
      });
    });

    group('formato válido', () {
      test('retorna null para email básico', () {
        expect(validateEmail('juan@gmail.com'), isNull);
      });

      test('retorna null para email con subdomain', () {
        expect(validateEmail('juan@mail.google.com'), isNull);
      });

      test('retorna null para email con guión en dominio', () {
        expect(validateEmail('juan@mi-sitio.com'), isNull);
      });

      test('retorna null para email con guión en usuario', () {
        expect(validateEmail('juan-garcia@email.com'), isNull);
      });

      test('retorna null para email con punto', () {
        expect(validateEmail('juan.garcia@email.com'), isNull);
      });

      test('retorna null para email de empresa', () {
        expect(validateEmail('contacto@empresa.com.co'), isNull);
      });

      test('retorna null para email con números', () {
        expect(validateEmail('user123@domain.com'), isNull);
      });

      test('retorna null para email con mayúsculas', () {
        expect(validateEmail('JUAN@DOMAIN.COM'), isNull);
      });

      test('ignora espacios al inicio y final', () {
        expect(validateEmail('  juan@email.com  '), isNull);
      });
    });
  });
}
