import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_usuarios/data/datasources/local/user_local_datasource.dart';
import 'package:gestion_usuarios/data/models/user_model.dart';
import 'package:gestion_usuarios/data/repositories_impl/user_repository_impl.dart';
import 'package:gestion_usuarios/domain/entities/user.dart';
import 'package:mocktail/mocktail.dart';

class MockUserLocalDatasource extends Mock implements UserLocalDatasource {}

void main() {
  group('UserRepositoryImpl', () {
    late UserLocalDatasource mockDatasource;
    late UserRepositoryImpl repository;

    final now = DateTime.now();
    final testUserModel = UserModel(
      id: 'test-id-123',
      firstName: 'Juan',
      lastName: 'Pérez',
      birthDate: DateTime(now.year - 25, now.month, now.day),
      email: 'juan@test.com',
      phone: '+573001234567',
    );

    final testUser = User(
      id: 'test-id-123',
      firstName: 'Juan',
      lastName: 'Pérez',
      birthDate: DateTime(now.year - 25, now.month, now.day),
      email: 'juan@test.com',
      phone: '+573001234567',
      addresses: const [],
    );

    setUpAll(() {
      registerFallbackValue(testUserModel);
    });

    setUp(() {
      mockDatasource = MockUserLocalDatasource();
      repository = UserRepositoryImpl(mockDatasource);
    });

    group('getAll', () {
      test(
        'retorna lista de usuarios convirtiendo modelos a entidades',
        () async {
          when(
            () => mockDatasource.getAll(),
          ).thenAnswer((_) async => [testUserModel]);

          final result = await repository.getAll();

          expect(result, hasLength(1));
          expect(result.first.id, testUser.id);
          expect(result.first.firstName, testUser.firstName);
          verify(() => mockDatasource.getAll()).called(1);
        },
      );

      test('retorna lista vacía cuando no hay usuarios', () async {
        when(() => mockDatasource.getAll()).thenAnswer((_) async => []);

        final result = await repository.getAll();

        expect(result, isEmpty);
      });

      test('propaga excepción cuando datasource falla', () async {
        when(
          () => mockDatasource.getAll(),
        ).thenThrow(Exception('Database error'));

        expect(() => repository.getAll(), throwsA(isA<Exception>()));
      });
    });

    group('getById', () {
      test('retorna usuario cuando existe', () async {
        when(
          () => mockDatasource.getById('test-id-123'),
        ).thenAnswer((_) async => testUserModel);

        final result = await repository.getById('test-id-123');

        expect(result, isNotNull);
        expect(result!.id, testUser.id);
      });

      test('retorna null cuando usuario no existe', () async {
        when(
          () => mockDatasource.getById('non-existent'),
        ).thenAnswer((_) async => null);

        final result = await repository.getById('non-existent');

        expect(result, isNull);
      });
    });

    group('create', () {
      test('guarda usuario en datasource', () async {
        when(
          () => mockDatasource.save(any<UserModel>()),
        ).thenAnswer((_) async {});

        await repository.create(testUser);

        verify(() => mockDatasource.save(any<UserModel>())).called(1);
      });

      test('propaga excepción cuando falla', () async {
        when(
          () => mockDatasource.save(any<UserModel>()),
        ).thenThrow(Exception('Save error'));

        expect(() => repository.create(testUser), throwsA(isA<Exception>()));
      });
    });

    group('update', () {
      test('actualiza usuario en datasource', () async {
        when(
          () => mockDatasource.save(any<UserModel>()),
        ).thenAnswer((_) async {});

        await repository.update(testUser);

        verify(() => mockDatasource.save(any<UserModel>())).called(1);
      });

      test('propaga excepción cuando falla', () async {
        when(
          () => mockDatasource.save(any<UserModel>()),
        ).thenThrow(Exception('Update error'));

        expect(() => repository.update(testUser), throwsA(isA<Exception>()));
      });
    });

    group('delete', () {
      test('elimina usuario del datasource', () async {
        when(
          () => mockDatasource.delete('test-id-123'),
        ).thenAnswer((_) async {});

        await repository.delete('test-id-123');

        verify(() => mockDatasource.delete('test-id-123')).called(1);
      });

      test('propaga excepción cuando falla', () async {
        when(
          () => mockDatasource.delete('test-id-123'),
        ).thenThrow(Exception('Delete error'));

        expect(
          () => repository.delete('test-id-123'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
