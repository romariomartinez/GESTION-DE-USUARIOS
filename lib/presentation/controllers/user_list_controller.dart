import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../domain/entities/user.dart';
import 'providers.dart';

final _logger = Logger('UserListController');

final userListControllerProvider =
    AsyncNotifierProvider<UserListController, List<User>>(
      UserListController.new,
    );

class UserListController extends AsyncNotifier<List<User>> {
  @override
  Future<List<User>> build() async {
    return _loadUsers();
  }

  Future<List<User>> _loadUsers() async {
    try {
      final getUsers = ref.read(getUsersProvider);
      final users = await getUsers();
      return users;
    } catch (e, stack) {
      _logger.severe('Error cargando usuarios', e, stack);
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadUsers);
  }

  Future<void> deleteUser(String userId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      try {
        await ref.read(userRepositoryProvider).delete(userId);
        final users = await _loadUsers();
        return users;
      } catch (e, stack) {
        _logger.severe('Error eliminando usuario', e, stack);
        showError(ref, 'No se pudo eliminar el usuario. Intenta de nuevo.');
        rethrow;
      }
    });
  }
}
