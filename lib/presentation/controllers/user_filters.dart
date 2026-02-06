enum UserOrderBy { name, age }

class UserFilters {
  final int? minAge;
  final int? maxAge;
  final String? city;
  final UserOrderBy orderBy;

  const UserFilters({
    this.minAge,
    this.maxAge,
    this.city,
    this.orderBy = UserOrderBy.name,
  });

  UserFilters copyWith({
    int? minAge,
    int? maxAge,
    String? city,
    UserOrderBy? orderBy,
  }) {
    return UserFilters(
      minAge: minAge,
      maxAge: maxAge,
      city: city,
      orderBy: orderBy ?? this.orderBy,
    );
  }

  static const empty = UserFilters();
}
