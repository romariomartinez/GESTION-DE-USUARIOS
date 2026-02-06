import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:gestion_usuarios/domain/entities/address.dart';
import 'package:gestion_usuarios/domain/repositories/address_repository.dart';
import 'package:gestion_usuarios/presentation/controllers/providers.dart';
import 'package:gestion_usuarios/presentation/screens/addresses/address_form_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockAddressRepository extends Mock implements AddressRepository {}

void main() {
  late MockAddressRepository mockAddressRepository;

  setUp(() {
    mockAddressRepository = MockAddressRepository();
    when(
      () => mockAddressRepository.getByUser(any()),
    ).thenAnswer((_) async => []);
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        addressRepositoryProvider.overrideWithValue(mockAddressRepository),
      ],
    );
  }

  group('AddressFormScreen', () {
    testWidgets('renderiza título para nueva dirección', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: const MaterialApp(home: AddressFormScreen(userId: 'user1')),
        ),
      );

      await tester.pump();

      expect(find.text('Nueva Dirección'), findsOneWidget);
    });

    testWidgets('renderiza título para edición de dirección', (tester) async {
      final address = Address(
        id: 'addr1',
        userId: 'user1',
        street: 'Calle 123',
        neighborhood: 'Centro',
        city: 'Bogotá',
        state: 'Cundinamarca',
        postalCode: '11001',
        label: 'Casa',
        isPrimary: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: MaterialApp(
            home: AddressFormScreen(userId: 'user1', address: address),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Editar Dirección'), findsOneWidget);
    });

    testWidgets('renderiza campos del formulario', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: const MaterialApp(home: AddressFormScreen(userId: 'user1')),
        ),
      );

      await tester.pump();

      // Verificar que hay TextFields
      expect(find.byType(TextField), findsAtLeastNWidgets(5));
    });

    testWidgets('renderiza selector de etiquetas', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: const MaterialApp(home: AddressFormScreen(userId: 'user1')),
        ),
      );

      await tester.pump();

      expect(find.text('Casa'), findsOneWidget);
      expect(find.text('Trabajo'), findsOneWidget);
      expect(find.text('Otro'), findsOneWidget);
    });

    testWidgets('renderiza switch de dirección principal', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: const MaterialApp(home: AddressFormScreen(userId: 'user1')),
        ),
      );

      await tester.pump();

      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('renderiza botón de guardar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: const MaterialApp(home: AddressFormScreen(userId: 'user1')),
        ),
      );

      await tester.pump();

      expect(find.text('Guardar Dirección'), findsOneWidget);
    });

    testWidgets('renderiza botón de actualizar en edición', (tester) async {
      final address = Address(
        id: 'addr1',
        userId: 'user1',
        street: 'Calle 123',
        neighborhood: 'Centro',
        city: 'Bogotá',
        state: 'Cundinamarca',
        postalCode: '11001',
        label: 'Casa',
        isPrimary: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: MaterialApp(
            home: AddressFormScreen(userId: 'user1', address: address),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Actualizar Dirección'), findsOneWidget);
    });

    testWidgets('renderiza scaffold con scroll', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: const MaterialApp(home: AddressFormScreen(userId: 'user1')),
        ),
      );

      await tester.pump();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('renderiza appbar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: const MaterialApp(home: AddressFormScreen(userId: 'user1')),
        ),
      );

      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renderiza botón en bottom', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: createContainer(),
          child: const MaterialApp(home: AddressFormScreen(userId: 'user1')),
        ),
      );

      await tester.pump();

      expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1));
    });
  });
}
