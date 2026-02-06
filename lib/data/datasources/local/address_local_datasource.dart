import 'package:hive/hive.dart';

import '../../models/address_model.dart';

abstract class AddressLocalDatasource {
  Future<List<AddressModel>> getByUserId(String userId);
  Future<void> save(AddressModel address);
  Future<void> delete(String id);
  Future<void> unsetPrimaryForUser(String userId);
}

class AddressLocalDatasourceImpl implements AddressLocalDatasource {
  static const _boxName = 'addresses';

  Future<Box<AddressModel>> _box() async {
    return Hive.openBox<AddressModel>(_boxName);
  }

  @override
  Future<List<AddressModel>> getByUserId(String userId) async {
    final box = await _box();
    return box.values.where((a) => a.userId == userId).toList();
  }

  @override
  Future<void> save(AddressModel address) async {
    final box = await _box();
    await box.put(address.id, address);
  }

  @override
  Future<void> delete(String id) async {
    final box = await _box();
    await box.delete(id);
  }

  @override
  Future<void> unsetPrimaryForUser(String userId) async {
    final box = await _box();

    final addresses = box.values.where(
      (a) => a.userId == userId && a.isPrimary,
    );

    for (final address in addresses) {
      final updated = AddressModel(
        id: address.id,
        userId: address.userId,
        street: address.street,
        neighborhood: address.neighborhood,
        city: address.city,
        state: address.state,
        postalCode: address.postalCode,
        label: address.label,
        isPrimary: false,
      );

      await box.put(address.id, updated);
    }
  }
}
