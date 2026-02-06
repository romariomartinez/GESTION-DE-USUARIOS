String? validateEmail(String value) {
  final trimmed = value.trim();

  if (trimmed.isEmpty) {
    return 'El email es obligatorio';
  }

  final emailRegex = RegExp(
    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
  );

  if (!emailRegex.hasMatch(trimmed)) {
    return 'Formato de email inválido';
  }

  return null;
}
