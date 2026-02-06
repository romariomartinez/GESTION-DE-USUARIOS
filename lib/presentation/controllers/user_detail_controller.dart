import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user.dart';
import 'providers.dart';

final userDetailControllerProvider =
    AsyncNotifierProviderFamily<UserDetailController, User?, String>(
  UserDetailController.new,
);

class UserDetailController
    extends FamilyAsyncNotifier<User?, String> {
  @override
  Future<User?> build(String userId) async {
    final repository = ref.read(userRepositoryProvider);
    return repository.getById(userId);
  }
}
