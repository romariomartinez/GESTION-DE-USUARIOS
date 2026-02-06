import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_usuarios/domain/entities/user.dart';
import 'package:gestion_usuarios/presentation/screens/user_list/user_list_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:gestion_usuarios/domain/repositories/user_repository.dart';
import 'package:gestion_usuarios/presentation/controllers/providers.dart';
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

  group('UserListScreen', () {
    testWidgets('renderiza empty state cuando no hay usuarios', (tester) async {
      when(() => mockUserRepository.getAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: const MaterialApp(home: UserListScreen()),
        ),
      );

      await tester.pump();

      expect(find.text('Sin usuarios'), findsOneWidget);
    });

    testWidgets('renderiza FAB cuando hay usuarios', (tester) async {
      final users = [
        User(
          id: '1',
          firstName: 'Juan',
          lastName: 'Pérez',
          birthDate: DateTime(1990, 1, 1),
          email: 'juan@test.com',
          phone: '+573001234567',
          addresses: const [],
        ),
      ];

      when(() => mockUserRepository.getAll()).thenAnswer((_) async => users);

      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: const MaterialApp(home: UserListScreen()),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renderiza lista de usuarios', (tester) async {
      final users = [
        User(
          id: '1',
          firstName: 'Juan',
          lastName: 'Pérez',
          birthDate: DateTime(1990, 1, 1),
          email: 'juan@test.com',
          phone: '+573001234567',
          addresses: const [],
        ),
        User(
          id: '2',
          firstName: 'María',
          lastName: 'García',
          birthDate: DateTime(1985, 5, 15),
          email: 'maria@test.com',
          phone: '+573009998877',
          addresses: const [],
        ),
      ];

      when(() => mockUserRepository.getAll()).thenAnswer((_) async => users);

      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: const MaterialApp(home: UserListScreen()),
        ),
      );

      await tester.pump();

      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('María García'), findsOneWidget);
    });
  });
}
