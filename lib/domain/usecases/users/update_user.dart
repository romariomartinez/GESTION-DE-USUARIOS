import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

class UpdateUser {
  final UserRepository repository;

  UpdateUser(this.repository);

  Future<void> call(User user) async {
    await repository.update(user);
  }
}
