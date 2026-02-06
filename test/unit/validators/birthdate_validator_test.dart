import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_usuarios/core/validators/birthdate_validator.dart';

void main() {
  group('validateBirthDate', () {
    test('retorna error cuando birthDate es null', () {
      expect(validateBirthDate(null), 'La fecha de nacimiento es obligatoria');
    });

    test('retorna error para menor de edad', () {
      final minorBirthDate = DateTime.now().subtract(
        const Duration(days: 365 * 17),
      );
      expect(validateBirthDate(minorBirthDate), 'Debe ser mayor de 18 años');
    });

    test('acepta fecha de nacimiento válida para adulto', () {
      final adultBirthDate = DateTime.now().subtract(
        const Duration(days: 365 * 25),
      );
      expect(validateBirthDate(adultBirthDate), isNull);
    });
  });
}
