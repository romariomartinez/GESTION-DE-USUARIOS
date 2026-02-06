import 'package:hive/hive.dart';

import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';
import '../models/address_model.dart';

class AddressRepositoryImpl implements AddressRepository {
  static const _boxName = 'addresses';

  // Constructor sin parámetros para uso con provider
  AddressRepositoryImpl();

  Future<Box<AddressModel>> _box() async {
    return Hive.openBox<AddressModel>(_boxName);
  }

  @override
  Future<List<Address>> getByUser(String userId) async {
    final box = await _box();

    return box.values
        .where((m) => m.userId == userId)
        .map((m) => m.toDomain())
        .toList();
  }

  @override
  Future<void> add({required String userId, required Address address}) async {
    final box = await _box();
    await box.put(address.id, AddressModel.fromDomain(address, userId));
  }

  @override
  Future<void> update({
    required String userId,
    required Address address,
  }) async {
    final box = await _box();
    await box.put(address.id, AddressModel.fromDomain(address, userId));
  }

  @override
  Future<void> delete({
    required String userId,
    required String addressId,
  }) async {
    final box = await _box();
    await box.delete(addressId);
  }

  @override
  Future<void> unsetPrimaryForUser(String userId) async {
    final box = await _box();

    final entries = box.values
        .where((m) => m.userId == userId && m.isPrimary)
        .toList();

    for (final model in entries) {
      final updated = AddressModel(
        id: model.id,
        userId: model.userId,
        street: model.street,
        neighborhood: model.neighborhood,
        city: model.city,
        state: model.state,
        postalCode: model.postalCode,
        label: model.label,
        isPrimary: false,
      );
      await box.put(model.id, updated);
    }
  }
}
