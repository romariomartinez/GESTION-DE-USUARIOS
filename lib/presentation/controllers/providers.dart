import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/user_local_datasource.dart';
import '../../data/datasources/local/address_local_datasource.dart';
import '../../data/repositories_impl/user_repository_impl.dart';
import '../../data/repositories_impl/address_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/address_repository.dart';
import '../../domain/usecases/users/get_users.dart';
import '../../domain/usecases/users/create_user.dart';
import '../../domain/usecases/users/update_user.dart';
import '../../domain/usecases/addresses/add_address.dart';
import '../../domain/usecases/addresses/update_address.dart';
import '../../domain/usecases/addresses/delete_address.dart';

/// Provider para manejo de errores global
final appErrorProvider = StateProvider<String?>((ref) => null);

/// Función para mostrar errores amigables
void showError(dynamic ref, String message) {
  ref.read(appErrorProvider.notifier).state = message;
}

/// Limpiar error
void clearError(dynamic ref) {
  ref.read(appErrorProvider.notifier).state = null;
}

// Data sources
final userLocalDatasourceProvider = Provider<UserLocalDatasource>(
  (ref) => UserLocalDatasourceImpl(),
);

final addressLocalDatasourceProvider = Provider<AddressLocalDatasource>(
  (ref) => AddressLocalDatasourceImpl(),
);

// Repositories
final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(ref.read(userLocalDatasourceProvider)),
);

final addressRepositoryProvider = Provider<AddressRepository>(
  (ref) => AddressRepositoryImpl(),
);

// Use cases - Users
final getUsersProvider = Provider<GetUsers>(
  (ref) => GetUsers(ref.read(userRepositoryProvider)),
);

final createUserProvider = Provider<CreateUser>(
  (ref) => CreateUser(ref.read(userRepositoryProvider)),
);

final updateUserProvider = Provider<UpdateUser>(
  (ref) => UpdateUser(ref.read(userRepositoryProvider)),
);

// Use cases - Addresses
final addAddressProvider = Provider<AddAddress>(
  (ref) => AddAddress(ref.read(addressRepositoryProvider)),
);

final updateAddressProvider = Provider<UpdateAddress>(
  (ref) => UpdateAddress(ref.read(addressRepositoryProvider)),
);

final deleteAddressProvider = Provider<DeleteAddress>(
  (ref) => DeleteAddress(ref.read(addressRepositoryProvider)),
);
