String? validateName(String value) {
  final trimmed = value.trim();

  if (trimmed.isEmpty) {
    return 'Este campo es obligatorio';
  }

  if (trimmed.length < 2) {
    return 'Debe tener al menos 2 caracteres';
  }

  return null;
}
