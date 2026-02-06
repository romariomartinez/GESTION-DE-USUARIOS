import 'package:hive/hive.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final DateTime birthDate;

  @HiveField(4)
  final String email;

  @HiveField(5)
  final String phone;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.email,
    required this.phone,
  });

  factory UserModel.fromEntity(User user) => UserModel(
        id: user.id,
        firstName: user.firstName,
        lastName: user.lastName,
        birthDate: user.birthDate,
        email: user.email,
        phone: user.phone,
      );

  User toEntity() => User(
        id: id,
        firstName: firstName,
        lastName: lastName,
        birthDate: birthDate,
        email: email,
        phone: phone,
      );
}
