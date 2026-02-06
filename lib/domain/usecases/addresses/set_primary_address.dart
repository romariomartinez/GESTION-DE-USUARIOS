import '../../entities/address.dart';
import '../../repositories/address_repository.dart';

class SetPrimaryAddress {
  final AddressRepository repository;

  SetPrimaryAddress(this.repository);

  Future<void> call({required String userId, required Address address}) async {
   
    await repository.unsetPrimaryForUser(userId);


    final updatedAddress = address.copyWith(isPrimary: true);
    await repository.update(userId: userId, address: updatedAddress);
  }
}
