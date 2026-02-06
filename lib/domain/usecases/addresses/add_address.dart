import '../../entities/address.dart';
import '../../repositories/address_repository.dart';

class AddAddress {
  final AddressRepository repository;

  AddAddress(this.repository);

  Future<void> call({required String userId, required Address address}) async {
    if (address.isPrimary) {
      await repository.unsetPrimaryForUser(userId);
    }

    await repository.add(userId: userId, address: address);
  }
}
