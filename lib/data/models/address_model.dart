import 'package:hive/hive.dart';
import '../../domain/entities/address.dart';

part 'address_model.g.dart';

@HiveType(typeId: 2)
class AddressModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String label;

  @HiveField(3)
  final String street;

  @HiveField(4)
  final String neighborhood;

  @HiveField(5)
  final String city;

  @HiveField(6)
  final String state;

  @HiveField(7)
  final String postalCode;

  @HiveField(8)
  final bool isPrimary;

  AddressModel({
    required this.id,
    required this.userId,
    required this.label,
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.isPrimary,
  });

  // DOMAIN → DATA
  factory AddressModel.fromDomain(Address address, String userId) {
    return AddressModel(
      id: address.id,
      userId: userId,
      label: address.label,
      street: address.street,
      neighborhood: address.neighborhood,
      city: address.city,
      state: address.state,
      postalCode: address.postalCode,
      isPrimary: address.isPrimary,
    );
  }

  // DATA → DOMAIN
  Address toDomain() {
    return Address(
      id: id,
      userId: userId,
      label: label,
      street: street,
      neighborhood: neighborhood,
      city: city,
      state: state,
      postalCode: postalCode,
      isPrimary: isPrimary,
    );
  }

  AddressModel copyWith({bool? isPrimary}) {
    return AddressModel(
      id: id,
      userId: userId,
      label: label,
      street: street,
      neighborhood: neighborhood,
      city: city,
      state: state,
      postalCode: postalCode,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}
