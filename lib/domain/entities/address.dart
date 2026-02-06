class Address {
  final String id;
  final String userId;
  final String street;
  final String neighborhood;
  final String city;
  final String state;
  final String postalCode;
  final String label;
  final bool isPrimary;

  const Address({
    required this.id,
    required this.userId,
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.label,
    required this.isPrimary,
  });

  Address copyWith({
    String? street,
    String? neighborhood,
    String? city,
    String? state,
    String? postalCode,
    String? label,
    bool? isPrimary,
  }) {
    return Address(
      id: id,
      userId: userId,
      street: street ?? this.street,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      label: label ?? this.label,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}
