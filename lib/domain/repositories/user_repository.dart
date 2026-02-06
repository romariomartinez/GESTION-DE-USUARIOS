import '../entities/user.dart';

abstract class UserRepository {
  Future<List<User>> getAll();

  Future<User?> getById(String id);

  Future<void> create(User user);

  Future<void> update(User user);

  Future<void> delete(String id);
}
