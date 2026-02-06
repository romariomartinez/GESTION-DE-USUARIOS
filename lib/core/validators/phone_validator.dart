class PhoneValidator {
  /// Valida un número de teléfono
  /// Retorna null si es válido, o un mensaje de error si no lo es
  static String? validate({
    required String phoneNumber,
    required String isoCode,
  }) {
    try {
      // Validación básica de longitud
      if (phoneNumber.isEmpty) {
        return 'El número de teléfono es requerido';
      }

      if (phoneNumber.length < 7) {
        return 'El número es muy corto';
      }

      if (phoneNumber.length > 15) {
        return 'El número es muy largo';
      }

      // Verificar que solo tenga dígitos
      final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      if (digitsOnly.length < 7 || digitsOnly.length > 15) {
        return 'Número de dígitos inválido';
      }

      return null;
    } catch (_) {
      return 'Número de teléfono inválido';
    }
  }

  /// Convierte código de país y número a formato E.164
  static String toE164(String countryCode, String phoneNumber) {
    final digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return '$countryCode$digits';
  }
}
