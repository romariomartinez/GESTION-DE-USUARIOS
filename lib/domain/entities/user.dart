import 'address.dart';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final String email;
  final String phone;


  final List<Address> addresses;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.email,
    required this.phone,
    this.addresses = const [],
  });

  /// Nombre completo
  String get fullName => '$firstName $lastName';

  
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month &&
            now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  /// Dirección principal 
  Address? get primaryAddress {
    try {
      return addresses.firstWhere((a) => a.isPrimary);
    } catch (_) {
      return null;
    }
  }

  /// Ciudad de la dirección principal
  String? get primaryCity => primaryAddress?.city;
}
