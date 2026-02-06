import 'package:hive/hive.dart';

import '../../models/user_model.dart';

abstract class UserLocalDatasource {
  Future<List<UserModel>> getAll();
  Future<UserModel?> getById(String id);
  Future<void> save(UserModel user);
  Future<void> delete(String id);
}

class UserLocalDatasourceImpl implements UserLocalDatasource {
  static const _boxName = 'users';

  Future<Box<UserModel>> _box() async {
    return Hive.openBox<UserModel>(_boxName);
  }

  @override
  Future<List<UserModel>> getAll() async {
    final box = await _box();
    return box.values.toList();
  }

  @override
  Future<UserModel?> getById(String id) async {
    final box = await _box();
    return box.get(id);
  }

  @override
  Future<void> save(UserModel user) async {
    final box = await _box();
    await box.put(user.id, user);
  }

  @override
  Future<void> delete(String id) async {
    final box = await _box();
    await box.delete(id);
  }
}
