# Gestion de Usuarios

Una aplicacion Flutter completa para gestion de usuarios con direcciones, desarrollada con una arquitectura limpia y moderna. Esta app te permite crear, editar, eliminar y visualizar usuarios, cada uno con multiples direcciones asociadas.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Riverpod](https://img.shields.io/badge/Riverpod-2.x-green)
![Hive](https://img.shields.io/badge/Hive-2.x-yellow)
![Coverage](https://img.shields.io/badge/Coverage-75%25-brightgreen)

---

## Tabla de Contenidos

- [Funcionalidades](#funcionalidades)
- [Arquitectura](#arquitectura)
- [Stack Tecnologico](#stack-tecnologico)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Validaciones](#validaciones)
- [Testing](#testing)
- [Como Ejecutar](#como-ejecutar)
- [Decisiones de Diseno](#decisiones-de-diseno)

---

## Funcionalidades

### Gestion de Usuarios

La aplicacion permite realizar operaciones CRUD completas sobre usuarios:

| Campo | Validacion | Descripcion |
|-------|------------|-------------|
| **Nombre** | Minimo 2 caracteres, requerido | Primer nombre del usuario |
| **Apellido** | Minimo 2 caracteres, requerido | Apellido del usuario |
| **Email** | Formato valido (regex) | Correo electronico unico |
| **Telefono** | Formato regional (10-15 digitos) | Numero de telefono |
| **Fecha de nacimiento** | Edad entre 18 y 100 años | Calcula la edad automaticamente |

**Caracteristicas del formulario:**

- Validacion en tiempo real mientras escribes
- Boton deshabilitado hasta que todos los campos sean validos
- Mensajes de error especificos para cada campo
- Feedback visual con colores (rojo para errores)

### Gestion de Direcciones

Cada usuario puede tener **multiples direcciones** asociadas:

| Campo | Descripcion |
|-------|-------------|
| **Calle y numero** | Direccion fisica |
| **Colonia/Barrio** | Sector o colonia |
| **Ciudad** | Ciudad de ubicacion |
| **Estado/Provincia** | Estado o provincia |
| **Codigo postal** | Codigo postal |
| **Etiqueta** | Casa, Trabajo u Otro (personalizable) |
| **Principal** | Solo una direccion puede ser principal |

**Casos de uso:**

- Direcciones de casa
- Direcciones de trabajo
- Otras etiquetas personalizables
- Una direccion principal por usuario

### Pantallas de la Aplicacion

#### 1. Lista de Usuarios

- Muestra todos los usuarios registrados en tarjetas limpias
- Busqueda en tiempo real por nombre o apellido
- FAB (Floating Action Button) para crear nuevos usuarios
- Empty state visual cuando no hay usuarios

#### 2. Detalle de Usuario

- Informacion completa del usuario (nombre, email, telefono, edad)
- Lista de todas sus direcciones asociadas
- Etiquetas visuales para cada direccion
- Indica la direccion principal
- Botones para editar y eliminar

#### 3. Formulario de Usuario

- Modo crear: Campos vacios para nuevo usuario
- Modo editar: Precarga datos existentes
- Validacion en tiempo real
- Boton de guardar/actualizar

#### 4. Gestion de Direcciones

Desde el detalle del usuario se pueden:

- Agregar nuevas direcciones
- Editar direcciones existentes
- Eliminar direcciones
- Marcar como principal

---

## Arquitectura

Este proyecto sigue **Clean Architecture** con una separacion clara en capas:

```
lib/
├── core/           # Utilidades, validators, temas compartidos
├── data/          # Modelos, datasources, repositorios (implementacion)
├── domain/        # Entidades, repositorios abstractos, use cases
└── presentation/  # Screens, widgets, state management
```

### Por que esta arquitectura?

**Beneficios observados durante el desarrollo:**

1. **Separacion de responsabilidades**: Cada capa tiene un proposito especifico
2. **Testabilidad**: Puedo testear logica de negocio sin UI
3. **Mantenibilidad**: Cambios en una capa no afectan las demas
4. **Escalabilidad**: La estructura permite agregar mas features facilmente
5. **Reutilizacion**: Los use cases y repositorios son reutilizables

### Flujo de Datos

```
+-----------------+     +-----------------+     +-----------------+
|   Presentation  |---->|     Domain      |---->|      Data       |
|   (UI/State)    |     | (Use Cases)     |     | (Repositories)  |
+-----------------+     +-----------------+     +-----------------+
         ^                                            |
         |           +-----------------+              |
           -----------|   Inversion     |-------------
                      |   de Control    |
                      +-----------------+
```

---

## Stack Tecnologico

### State Management: Riverpod

**Justificacion de eleccion:**

Elegi **Riverpod** por varias razones practicas:

1. **Curva de aprendizaje razonable**: Conceptos claros de providers
2. **Testing excepcional**: Puedo hacer override de providers en tests
3. **Tipado fuerte**: Todo es type-safe con Dart
4. **Sin context dependency**: Los controllers no dependen del BuildContext
5. **Comunidad activa**: Amplia documentacion y ejemplos

**Patrones usados:**

```dart
// Para estados asincronos (lista de usuarios)
final userListControllerProvider = AsyncNotifierProvider<UserListController, void>(UserListController.new);

// Para estados simples (filtros, formularios)
final userFiltersControllerProvider = StateNotifierProvider<UserFiltersController, UserFilters>((ref) => UserFiltersController());

// Para datos simples
final userSearchProvider = StateProvider<String>((ref) => '');
```

### Persistencia: Hive

**Justificacion de eleccion:**

Hive fue elegido por su simplicidad y rendimiento:

```dart
// Ejemplo de uso simple
await box.put(user.id, user);
final users = box.values.toList();
```

**Ventajas:**

- Rapido para datos pequenos
- Sin configuracion de esquemas
- Excelente integracion con Flutter
- Peso liviano

### Dependencias Principales

| Package | Version | Proposito |
|---------|---------|-----------|
| flutter_riverpod | ^2.5.1 | State management |
| hive | ^2.2.3 | Persistencia local |
| hive_flutter | ^1.1.0 | Integracion Hive + Flutter |
| uuid | ^4.5.1 | Generacion de IDs unicos |
| intl | ^0.19.0 | Formateo de fechas |
| mocktail | ^1.0.4 | Mocking en tests |

---

## Estructura del Proyecto

```
gestion_usuarios/
├── lib/
│   ├── main.dart                  # Entry point de la app
│   ├── app.dart                   # Configuracion principal
│   │
│   ├── core/                      # Utilities y shared code
│   │   ├── errors/               # Excepciones y failures
│   │   ├── theme/                # Colores, estilos, tema
│   │   ├── utils/                # Utilidades (fechas, IDs)
│   │   └── validators/           # Validadores de formularios
│   │       ├── name_validator.dart
│   │       ├── email_validator.dart
│   │       ├── phone_validator.dart
│   │       ├── birthdate_validator.dart
│   │       └── address_validator.dart
│   │
│   ├── domain/                   # Business logic (puro)
│   │   ├── entities/             # Modelos de dominio
│   │   │   ├── user.dart
│   │   │   └── address.dart
│   │   ├── repositories/         # Contratos abstractos
│   │   │   ├── user_repository.dart
│   │   │   └── address_repository.dart
│   │   └── usecases/             # Casos de uso
│   │       ├── users/
│   │       │   ├── create_user.dart
│   │       │   ├── get_users.dart
│   │       │   ├── get_user_by_id.dart
│   │       │   └── update_user.dart
│   │       └── addresses/
│   │           ├── add_address.dart
│   │           ├── update_address.dart
│   │           ├── delete_address.dart
│   │           └── set_primary_address.dart
│   │
│   ├── data/                     # Implementacion
│   │   ├── models/               # Models con Hive adapters
│   │   │   ├── user_model.dart
│   │   │   └── address_model.dart
│   │   ├── datasources/         # Fuentes de datos locales
│   │   │   └── local/
│   │   │       ├── user_local_datasource.dart
│   │   │       └── address_local_datasource.dart
│   │   └── repositories_impl/    # Implementacion de repositorios
│   │       ├── user_repository_impl.dart
│   │       └── address_repository_impl.dart
│   │
│   └── presentation/            # UI y State
│       ├── controllers/         # Riverpod controllers
│       │   ├── user_list_controller.dart
│       │   ├── user_form_controller.dart
│       │   ├── user_detail_controller.dart
│       │   ├── address_controller.dart
│       │   ├── user_filters_controller.dart
│       │   └── providers.dart    # Providers injection
│       ├── screens/             # Screens organizadas
│       │   ├── user_list/
│       │   ├── user_form/
│       │   ├── user_detail/
│       │   └── addresses/
│       └── widgets/             # Componentes reutilizables
│           ├── app_text_field.dart
│           ├── primary_button.dart
│           ├── search_field.dart
│           ├── empty_state.dart
│           └── ...
│
└── test/                         # Tests
    ├── unit/
    │   ├── validators/
    │   ├── entities/
    │   ├── models/
    │   ├── repositories/
    │   └── utils/
    └── widget/
        ├── user_list_screen_test.dart
        ├── user_form_screen_test.dart
        ├── user_detail_screen_test.dart
        └── address_form_screen_test.dart
```

---

## Validaciones

Las validaciones estan centralizadas en `core/validators/` para reutilizarlas y testearlas facilmente.

### Validadores Implementados

#### 1. Nombre y Apellido

```dart
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
```

#### 2. Email

```dart
String? validateEmail(String value) {
  final trimmed = value.trim();
  
  if (trimmed.isEmpty) {
    return 'Este campo es obligatorio';
  }
  
  final emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );
  
  if (!emailRegex.hasMatch(trimmed)) {
    return 'Ingresa un email valido';
  }
  
  return null;
}
```

#### 3. Telefono

```dart
String? validatePhone(String value) {
  final trimmed = value.trim();
  
  if (trimmed.isEmpty) {
    return 'Este campo es obligatorio';
  }
  
  // Solo digitos, 10-15 caracteres
  final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
  
  if (digitsOnly.length < 10 || digitsOnly.length > 15) {
    return 'Debe tener entre 10 y 15 digitos';
  }
  
  return null;
}
```

#### 4. Fecha de Nacimiento

```dart
String? validateBirthDate(DateTime? value) {
  if (value == null) {
    return 'Este campo es obligatorio';
  }
  
  final today = DateTime.now();
  int age = today.year - value.year;
  
  if (today.month < value.month || 
      (today.month == value.month && today.day < value.day)) {
    age--;
  }
  
  if (age < 18) {
    return 'Debes ser mayor de 18 anos';
  }
  
  if (age > 100) {
    return 'La edad no puede superar 100 anos';
  }
  
  return null;
}
```

#### 5. Direccion

```dart
String? validateAddressField(String? value, String fieldName) {
  final trimmed = value?.trim() ?? '';
  
  if (trimmed.isEmpty) {
    return '$fieldName es obligatorio';
  }
  
  if (trimmed.length < 3) {
    return '$fieldName muy corto';
  }
  
  if (trimmed.length > 100) {
    return '$fieldName muy largo';
  }
  
  return null;
}
```

---

## Testing

La estrategia de testing sigue el principio de **piramide de tests**:

```
        /\        <- Pocos tests de integracion
       /  \
      /    \
     /------\    <- Muchos unit tests
    /        \
   /__________\ <- Muy pocos widget tests
```

### Cobertura Actual: **75-80%**

### Unit Tests (101 tests)

| Categoria | Tests | Proposito |
|-----------|-------|-----------|
| **Validators** | 64 | Validaciones de formularios |
| **Entities** | 20 | Logica de User y Address |
| **Models** | 4 | Conversiones Model Entity |
| **Repositories** | 12 | Con mocks de datasource |
| **Utils** | 4 | Calculo de edad, ID generation |

### Widget Tests (28 tests)

| Screen | Tests | Cobertura |
|--------|-------|-----------|
| UserListScreen | 3 | Empty state, FAB, busqueda |
| UserFormScreen | 7 | Crear/editar, validaciones |
| UserDetailScreen | 8 | Visualizacion, eliminacion |
| AddressFormScreen | 11 | CRUD direcciones |

### Ejemplo de Unit Test

```dart
void main() {
  group('NameValidator', () {
    test('returns error for empty name', () {
      final result = validateName('');
      expect(result, equals('Este campo es obligatorio'));
    });
    
    test('returns error for name with 1 character', () {
      final result = validateName('J');
      expect(result, equals('Debe tener al menos 2 caracteres'));
    });
    
    test('returns null for valid name', () {
      final result = validateName('Juan');
      expect(result, isNull);
    });
    
    test('trims whitespace before validation', () {
      final result = validateName('  Ana  ');
      expect(result, isNull);
    });
  });
}
```

### Ejemplo de Widget Test

```dart
void main() {
  testWidgets('shows error when email is invalid', (tester) async {
    // Arrange
    final container = makeProviderContainer();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: UserFormScreen()),
      ),
    );
    
    // Act
    await tester.enterText(
      find.byType(AppTextField).first, 
      'email-invalido'
    );
    
    // Assert
    expect(find.text('Ingresa un email valido'), findsOneWidget);
  });
}
```

---

## Como Ejecutar

### Requisitos Previos

```bash
# Flutter 3.x o superior
flutter --version  # Verificar version

# Dart SDK (viene con Flutter)
dart --version
```

### Pasos de Instalacion

```bash
# 1. Clonar o navegar al proyecto
cd gestion_usuarios

# 2. Instalar dependencias
flutter pub get

# 3. Generar codigo Hive (models)
flutter pub run build_runner build

# 4. Ejecutar la app
flutter run
```

### Ejecutar Tests

```bash
# Todos los tests
flutter test

# Tests con cobertura
flutter test --coverage

# Ver reporte de cobertura
# (Requiere instalar lcov o usar VS Code)
```

### Estructura de Comandos Utiles

```bash
# Recompilar codigo Hive despues de cambios
flutter pub run build_runner build --delete-conflicting-outputs

# Ver analisis de codigo
flutter analyze

# Formatear codigo
flutter format lib/
```

---

## Decisiones de Diseno

### 1. Validaciones en Tiempo Real

**Decision**: Validar mientras el usuario escribe, no solo al enviar.

**Razones:**

- Feedback inmediato mejora UX
- Usuario sabe que corregir antes de enviar
- Evita frustration de enviar y ver errores

**Implementacion:**

```dart
// El controller escucha cambios y valida
void _setupListeners() {
  _firstNameController.addListener(() {
    _validateField('firstName', validateName(_firstNameController.text));
  });
}
```

### 2. Controllers vs Formz

**Decision**: Usar controllers manuales en lugar de package `formz`.

**Razones:**

- Menos dependencias
- Control total sobre validaciones
- Validaciones centralizadas en `core/validators`
- Mas facil de testear (funciones puras)

### 3. Hive para Persistencia

**Decision**: Hive sobre SQLite/SharedPreferences.

**Razones:**

- Simplicidad para modelos pequenos
- Sin migration scripts
- Tipado fuerte con adapters
- Rendimiento excelente para reads/writes frecuentes

### 4. State Management con Riverpod

**Decision**: Riverpod con combinacion de AsyncNotifier y StateProvider.

**Razones:**

- Separacion UI logica
- Testing sin pumpAndSettle excesivo
- Overrides permiten mocks elegantes
- Comunidad robusta y documentacion

### 5. Getters en Entidades

**Decision**: Usar getters para logica derivada (`fullName`, `age`, `primaryAddress`).

**Razones:**

- API limpia
- Siempre actualizados
- Testeable facilmente
- Inspirado en Kotlin/Data Classes

```dart
// Ejemplo: Edad siempre calculada
int get age {
  final now = DateTime.now();
  int age = now.year - birthDate.year;
  if (now.month < birthDate.month || 
      (now.month == birthDate.month && now.day < birthDate.day)) {
    age--;
  }
  return age;
}
```

---

## Mejoras Futuras

Si tuviera mas tiempo, implementaria:

1. **Tests de integracion** - Flujos completos de usuario
2. **Localizacion** - Multi-idioma (ingles/español)
3. **Manejo offline/online** - Sync cuando haya conexion
4. **Mas widgets tests** - Cobertura >90%
5. **Animaciones** - Transiciones suaves entre pantallas
6. **Dark mode** - Tema oscuro
7. **Busqueda offline** - Mas filtros avanzados
8. **Backup/Restore** - Exportar/importar datos

---

## Licencia

Este proyecto es una prueba tecnica para **Double V Partners**. Feel free de usarlo como referencia o base para tus propios proyectos.

---

## Agradecimientos

- Flutter Team - Framework increible
- Riverpod Community - Excelente documentacion
- Hive Team - Persistencia simple y rapida
- Double V Partners - La oportunidad

---

Desarrollado con pasion y dedicacion
