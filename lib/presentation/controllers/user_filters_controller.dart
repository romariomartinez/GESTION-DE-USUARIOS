import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_filters.dart';

final userFiltersProvider =
    StateNotifierProvider<UserFiltersController, UserFilters>(
  (ref) => UserFiltersController(),
);

class UserFiltersController extends StateNotifier<UserFilters> {
  UserFiltersController() : super(UserFilters.empty);

  void setMinAge(int? value) =>
      state = state.copyWith(minAge: value);

  void setMaxAge(int? value) =>
      state = state.copyWith(maxAge: value);

  void setCity(String? value) =>
      state = state.copyWith(city: value?.trim());

  void setOrderBy(UserOrderBy orderBy) =>
      state = state.copyWith(orderBy: orderBy);

  void reset() => state = UserFilters.empty;
}
