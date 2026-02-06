import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local/user_local_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserLocalDatasource localDatasource;

  UserRepositoryImpl(this.localDatasource);

  @override
  Future<List<User>> getAll() async {
    final models = await localDatasource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<User?> getById(String id) async {
    final model = await localDatasource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<void> create(User user) async {
    final model = UserModel.fromEntity(user);
    await localDatasource.save(model);
  }

  @override
  Future<void> update(User user) async {
    final model = UserModel.fromEntity(user);
    await localDatasource.save(model);
  }

  @override
  Future<void> delete(String id) async {
    await localDatasource.delete(id);
  }
}
