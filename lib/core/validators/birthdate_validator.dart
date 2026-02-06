import '../utils/date_utils.dart';

String? validateBirthDate(DateTime? birthDate) {
  if (birthDate == null) {
    return 'La fecha de nacimiento es obligatoria';
  }

  final age = calculateAge(birthDate);

  if (age < 18) {
    return 'Debe ser mayor de 18 años';
  }

  if (age > 100) {
    return 'Edad inválida';
  }

  return null;
}
