import '../../repositories/address_repository.dart';

class DeleteAddress {
  final AddressRepository repository;

  DeleteAddress(this.repository);

  Future<void> call({
    required String userId,
    required String addressId,
  }) async {
    await repository.delete(
      userId: userId,
      addressId: addressId,
    );
  }
}