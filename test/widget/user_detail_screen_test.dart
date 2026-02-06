import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:gestion_usuarios/domain/entities/user.dart';
import 'package:gestion_usuarios/domain/entities/address.dart';
import 'package:gestion_usuarios/domain/repositories/user_repository.dart';
import 'package:gestion_usuarios/domain/repositories/address_repository.dart';
import 'package:gestion_usuarios/presentation/controllers/providers.dart';
import 'package:gestion_usuarios/presentation/screens/user_detail/user_detail_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockAddressRepository extends Mock implements AddressRepository {}

void main() {
  late MockUserRepository mockUserRepository;
  late MockAddressRepository mockAddressRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
    mockAddressRepository = MockAddressRepository();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        userRepositoryProvider.overrideWithValue(mockUserRepository),
        addressRepositoryProvider.overrideWithValue(mockAddressRepository),
      ],
    );
  }

  group('UserDetailScreen', () {
    testWidgets('renderiza título Perfil', (tester) async {
      final user = User(
        id: '1',
        firstName: 'Juan',
        lastName: 'Pérez',
        birthDate: DateTime(1990, 1, 1),
        email: 'juan@test.com',
        phone: '+573001234567',
        addresses: const [],
      );

      when(() => mockUserRepository.getById('1')).thenAnswer((_) async => user);
      when(
        () => mockAddressRepository.getByUser('1'),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: const MaterialApp(home: UserDetailScreen(userId: '1')),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Perfil'), findsOneWidget);
    });

    testWidgets('renderiza usuario no encontrado', (tester) async {
      when(
        () => mockUserRepository.getById('999'),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: const MaterialApp(home: UserDetailScreen(userId: '999')),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Usuario no encontrado'), findsOneWidget);
    });

    testWidgets('renderiza información del usuario', (tester) async {
      final user = User(
        id: '1',
        firstName: 'Juan',
        lastName: 'Pérez',
        birthDate: DateTime(1990, 1, 1),
        email: 'juan@test.com',
        phone: '+573001234567',
        addresses: const [],
      );

      when(() => mockUserRepository.getById('1')).thenAnswer((_) async => user);
      when(
        () => mockAddressRepository.getByUser('1'),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: const MaterialApp(home: UserDetailScreen(userId: '1')),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Información Personal'), findsOneWidget);
    });

    testWidgets('renderiza sección de información personal', (tester) async {
      final user = User(
        id: '1',
        firstName: 'Juan',
        lastName: 'Pérez',
        birthDate: DateTime(1990, 1, 1),
        email: 'juan@test.com',
        phone: '+573001234567',
        addresses: const [],
      );

      when(() => mockUserRepository.getById('1')).thenAnswer((_) async => user);
      when(
        () => mockAddressRepository.getByUser('1'),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: const MaterialApp(home: UserDetailScreen(userId: '1')),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Nombre completo'), findsOneWidget);
    });

    testWidgets('renderiza email del usuario', (tester) async {
      final user = User(
        id: '1',
        firstName: 'Juan',
        lastName: 'Pérez',
        birthDate: DateTime(1990, 1, 1),
        email: 'juan@test.com',
        phone: '+573001234567',
        addresses: const [],
      );

      when(() => mockUserRepository.getById('1')).thenAnswer((_) async => user);
      when(
        () => mockAddressRepository.getByUser('1'),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: const MaterialApp(home: UserDetailScreen(userId: '1')),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Email'), findsOneWidget);
    });

    testWidgets('renderiza botón de gestionar direcciones', (tester) async {
      final user = User(
        id: '1',
        firstName: 'Juan',
        lastName: 'Pérez',
        birthDate: DateTime(1990, 1, 1),
        email: 'juan@test.com',
        phone: '+573001234567',
        addresses: const [],
      );

      when(() => mockUserRepository.getById('1')).thenAnswer((_) async => user);
      when(
        () => mockAddressRepository.getByUser('1'),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: const MaterialApp(home: UserDetailScreen(userId: '1')),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Gestionar Direcciones'), findsOneWidget);
    });

    testWidgets('renderiza avatar del usuario', (tester) async {
      final user = User(
        id: '1',
        firstName: 'Juan',
        lastName: 'Pérez',
        birthDate: DateTime(1990, 1, 1),
        email: 'juan@test.com',
        phone: '+573001234567',
        addresses: const [],
      );

      when(() => mockUserRepository.getById('1')).thenAnswer((_) async => user);
      when(
        () => mockAddressRepository.getByUser('1'),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: const MaterialApp(home: UserDetailScreen(userId: '1')),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('JP'), findsOneWidget);
    });

    testWidgets('renderiza dirección principal si existe', (tester) async {
      final user = User(
        id: '1',
        firstName: 'Juan',
        lastName: 'Pérez',
        birthDate: DateTime(1990, 1, 1),
        email: 'juan@test.com',
        phone: '+573001234567',
        addresses: const [],
      );

      final addresses = [
        Address(
          id: 'addr1',
          userId: '1',
          street: 'Calle 123',
          neighborhood: 'Centro',
          city: 'Bogotá',
          state: 'Cundinamarca',
          postalCode: '11001',
          label: 'Casa',
          isPrimary: true,
        ),
      ];

      when(() => mockUserRepository.getById('1')).thenAnswer((_) async => user);
      when(
        () => mockAddressRepository.getByUser('1'),
      ).thenAnswer((_) async => addresses);

      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: const MaterialApp(home: UserDetailScreen(userId: '1')),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Casa'), findsOneWidget);
    });
  });
}
