import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../domain/entities/user.dart';
import 'providers.dart';
import 'user_list_controller.dart';

final _logger = Logger('UserFormController');

final userFormControllerProvider =
    AsyncNotifierProvider<UserFormController, void>(UserFormController.new);

class UserFormController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createUser(User user) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      try {
        await ref.read(createUserProvider)(user);
        await ref.read(userListControllerProvider.notifier).refresh();
        clearError(ref);
      } catch (e, stack) {
        _logger.severe('Error creando usuario', e, stack);
        showError(
          ref,
          'No se pudo crear el usuario. Verifica los datos e intenta de nuevo.',
        );
        rethrow;
      }
    });
  }

  Future<void> updateUser(User user) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      try {
        await ref.read(updateUserProvider)(user);
        await ref.read(userListControllerProvider.notifier).refresh();
        clearError(ref);
      } catch (e, stack) {
        _logger.severe('Error actualizando usuario', e, stack);
        showError(ref, 'No se pudo actualizar el usuario. Intenta de nuevo.');
        rethrow;
      }
    });
  }

  Future<void> deleteUser(String userId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      try {
        await ref.read(userRepositoryProvider).delete(userId);
        await ref.read(userListControllerProvider.notifier).refresh();
        clearError(ref);
      } catch (e, stack) {
        _logger.severe('Error eliminando usuario', e, stack);
        showError(ref, 'No se pudo eliminar el usuario. Intenta de nuevo.');
        rethrow;
      }
    });
  }
}
