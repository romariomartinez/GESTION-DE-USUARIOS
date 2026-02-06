import '../entities/address.dart';

abstract class AddressRepository {
  Future<List<Address>> getByUser(String userId);

  Future<void> add({
    required String userId,
    required Address address,
  });

  Future<void> update({
    required String userId,
    required Address address,
  });

  Future<void> delete({
    required String userId,
    required String addressId,
  });

  Future<void> unsetPrimaryForUser(String userId);
}
