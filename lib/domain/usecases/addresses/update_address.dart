import '../../entities/address.dart';
import '../../repositories/address_repository.dart';

class UpdateAddress {
  final AddressRepository repository;

  UpdateAddress(this.repository);

  Future<void> call({required String userId, required Address address}) async {
    // Si la dirección se marca como principal, desmarcar las demás
    if (address.isPrimary) {
      await repository.unsetPrimaryForUser(userId);
    }

    await repository.update(userId: userId, address: address);
  }
}
