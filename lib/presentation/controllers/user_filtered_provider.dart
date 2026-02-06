import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user.dart';
import 'user_list_controller.dart';
import 'user_search_provider.dart';
import 'user_filters_controller.dart';
import 'user_filters.dart';

final filteredUsersProvider =
    Provider<AsyncValue<List<User>>>((ref) {
  final usersAsync = ref.watch(userListControllerProvider);
  final search =
      ref.watch(userSearchQueryProvider).toLowerCase();
  final filters = ref.watch(userFiltersProvider);

  return usersAsync.whenData((users) {
    var result = users;

    // Búsqueda por nombre
    if (search.isNotEmpty) {
      result = result
          .where((u) =>
              u.fullName.toLowerCase().contains(search))
          .toList();
    }

    // Rango de edad
    if (filters.minAge != null) {
      result = result
          .where((u) => u.age >= filters.minAge!)
          .toList();
    }

    if (filters.maxAge != null) {
      result = result
          .where((u) => u.age <= filters.maxAge!)
          .toList();
    }

    // Ciudad (si tienes dirección principal)
    if (filters.city != null && filters.city!.isNotEmpty) {
      result = result
          .where((u) =>
              u.primaryCity
                  ?.toLowerCase()
                  .contains(filters.city!.toLowerCase()) ??
              false)
          .toList();
    }

    // Ordenamiento
    switch (filters.orderBy) {
      case UserOrderBy.age:
        result.sort((a, b) => a.age.compareTo(b.age));
        break;
      case UserOrderBy.name:
        result.sort((a, b) => a.fullName.compareTo(b.fullName));
        break;
    }

    return result;
  });
});
