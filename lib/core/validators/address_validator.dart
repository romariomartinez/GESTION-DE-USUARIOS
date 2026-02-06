String? validateStreet(String? value) {
  final trimmed = value?.trim() ?? '';

  if (trimmed.isEmpty) {
    return 'La calle y número son obligatorios';
  }

  if (trimmed.length < 3) {
    return 'Debe tener al menos 3 caracteres';
  }

  return null;
}

String? validateNeighborhood(String? value) {
  final trimmed = value?.trim() ?? '';

  if (trimmed.isEmpty) {
    return null; // Campo opcional
  }

  if (trimmed.length < 2) {
    return 'Debe tener al menos 2 caracteres';
  }

  return null;
}

String? validateCity(String? value) {
  final trimmed = value?.trim() ?? '';

  if (trimmed.isEmpty) {
    return 'La ciudad es obligatoria';
  }

  if (trimmed.length < 2) {
    return 'Debe tener al menos 2 caracteres';
  }

  return null;
}

String? validateState(String? value) {
  final trimmed = value?.trim() ?? '';

  if (trimmed.isEmpty) {
    return 'El estado/provincia es obligatorio';
  }

  if (trimmed.length < 2) {
    return 'Debe tener al menos 2 caracteres';
  }

  return null;
}

String? validatePostalCode(String? value) {
  final trimmed = value?.trim() ?? '';

  if (trimmed.isEmpty) {
    return 'El código postal es obligatorio';
  }

  // Validar formato básico de código postal (3-10 caracteres alfanuméricos)
  if (trimmed.length < 3 || trimmed.length > 10) {
    return 'Debe tener entre 3 y 10 caracteres';
  }

  if (!RegExp(r'^[a-zA-Z0-9\-]+$').hasMatch(trimmed)) {
    return 'Solo se permiten letras, números y guiones';
  }

  return null;
}
