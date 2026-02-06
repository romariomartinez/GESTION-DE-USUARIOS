import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:gestion_usuarios/domain/entities/user.dart';
import 'package:gestion_usuarios/domain/repositories/user_repository.dart';
import 'package:gestion_usuarios/presentation/controllers/providers.dart';
import 'package:gestion_usuarios/presentation/screens/user_form/user_form_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [userRepositoryProvider.overrideWithValue(mockUserRepository)],
    );
  }

  group('UserFormScreen', () {
    testWidgets('renderiza título para nuevo usuario', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: const MaterialApp(home: UserFormScreen()),
        ),
      );

      await tester.pump();

      expect(find.text('Nuevo Usuario'), findsOneWidget);
    });

    testWidgets('renderiza título para edición de usuario', (tester) async {
      final user = User(
        id: '1',
        firstName: 'Juan',
        lastName: 'Pérez',
        birthDate: DateTime(1990, 1, 1),
        email: 'juan@test.com',
        phone: '+573001234567',
        addresses: const [],
      );

      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: MaterialApp(home: UserFormScreen(user: user)),
        ),
      );

      await tester.pump();

      expect(find.text('Editar Usuario'), findsOneWidget);
    });

    testWidgets('renderiza campos de texto', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: const MaterialApp(home: UserFormScreen()),
        ),
      );

      await tester.pump();

      expect(find.byType(TextFormField), findsAtLeastNWidgets(3));
    });

    testWidgets('renderiza sección de información personal', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: const MaterialApp(home: UserFormScreen()),
        ),
      );

      await tester.pump();

      expect(find.text('Información Personal'), findsOneWidget);
    });

    testWidgets('renderiza sección de contacto', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: const MaterialApp(home: UserFormScreen()),
        ),
      );

      await tester.pump();

      expect(find.text('Contacto'), findsOneWidget);
    });

    testWidgets('renderiza botón de cancelar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: const MaterialApp(home: UserFormScreen()),
        ),
      );

      await tester.pump();

      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('renderiza fecha de nacimiento field', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: const MaterialApp(home: UserFormScreen()),
        ),
      );

      await tester.pump();

      expect(find.text('Fecha de nacimiento'), findsOneWidget);
    });
  });
}
