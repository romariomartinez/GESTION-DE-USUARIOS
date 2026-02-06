import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/user.dart';
import '../../../core/theme/app_colors.dart';
import '../../controllers/user_list_controller.dart';
import '../../controllers/user_form_controller.dart';
import '../../controllers/user_search_provider.dart';
import '../../controllers/user_filtered_provider.dart';
import '../../controllers/user_filters_controller.dart';
import '../../controllers/user_filters.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/primary_button.dart';
import '../user_form/user_form_screen.dart';
import '../user_detail/user_detail_screen.dart';


class UserListScreen extends ConsumerWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(userListControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, ref),
     
      floatingActionButton: usersState.maybeWhen(
        data: (users) => users.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserFormScreen()),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Nuevo Usuario'),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textInverse,
              )
            : null,
        orElse: () => null,
      ),
      body: usersState.when(
        loading: () => const LoadingView(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (_) => _UserListContent(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: AppColors.background,
      title: const Text(
        'Usuarios',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            showSearch(context: context, delegate: _UserSearchDelegate(ref));
          },
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const _UserFiltersSheet(),
            );
          },
        ),
      ],
    );
  }
}

class _UserListContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredUsers = ref.watch(filteredUsersProvider);

    return filteredUsers.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (users) {
        // UN SOLO PUNTO DE DECISIÓN
        if (users.isEmpty) {
          return const EmptyUsersState();
        }
        return UserListView(users: users);
      },
    );
  }
}


class EmptyUsersState extends StatelessWidget {
  const EmptyUsersState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.people_outline,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Sin usuarios',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Comienza agregando usuarios a tu lista\npara gestionar su información.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Crear usuario',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UserFormScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserListView extends ConsumerWidget {
  final List<User> users;

  const UserListView({super.key, required this.users});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final user = users[index];
        return _UserCard(user: user);
      },
    );
  }
}

class _UserCard extends ConsumerWidget {
  final User user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserDetailScreen(userId: user.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(name: user.fullName, size: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (user.primaryCity != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user.primaryCity!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserFormScreen(user: user),
                      ),
                    );
                  }
                  if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Eliminar usuario'),
                        content: Text(
                          '¿Estás seguro de eliminar a ${user.firstName}?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                            ),
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref
                          .read(userFormControllerProvider.notifier)
                          .deleteUser(user.id);
                    }
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Eliminar',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Search delegate para búsqueda integrada.
class _UserSearchDelegate extends SearchDelegate {
  final WidgetRef ref;

  _UserSearchDelegate(this.ref);

  @override
  String? get searchFieldLabel => 'Buscar usuarios...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            ref.read(userSearchQueryProvider.notifier).state = '';
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final users = ref.read(filteredUsersProvider).value ?? [];
    final results = users
        .where(
          (u) =>
              u.fullName.toLowerCase().contains(query.toLowerCase()) ||
              u.email.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return _SearchResultsList(
      users: results,
      onTap: (user) {
        close(context, null);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserDetailScreen(userId: user.id)),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final users = ref.read(filteredUsersProvider).value ?? [];
    final suggestions = users
        .where(
          (u) =>
              u.fullName.toLowerCase().contains(query.toLowerCase()) ||
              u.email.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return _SearchResultsList(
      users: suggestions,
      onTap: (user) {
        close(context, null);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserDetailScreen(userId: user.id)),
        );
      },
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  final List<User> users;
  final void Function(User) onTap;

  const _SearchResultsList({required this.users, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            const Text(
              'No se encontraron resultados',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final user = users[index];
        return Card(
          child: ListTile(
            leading: UserAvatar(name: user.fullName, size: 40),
            title: Text(user.fullName),
            subtitle: Text(user.email),
            onTap: () => onTap(user),
          ),
        );
      },
    );
  }
}

/// Sheet de filtros.
class _UserFiltersSheet extends ConsumerWidget {
  const _UserFiltersSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(userFiltersProvider);

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Rango de edad
          const Text(
            'Rango de Edad',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Mínima',
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) => ref
                      .read(userFiltersProvider.notifier)
                      .setMinAge(int.tryParse(v)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Máxima',
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) => ref
                      .read(userFiltersProvider.notifier)
                      .setMaxAge(int.tryParse(v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Ciudad
          const Text(
            'Ciudad',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'Filtrar por ciudad',
              isDense: true,
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (v) => ref.read(userFiltersProvider.notifier).setCity(v),
          ),
          const SizedBox(height: 20),

          // Ordenar por
          const Text(
            'Ordenar por',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FilterChip(
                label: const Text('Nombre'),
                selected: filters.orderBy == UserOrderBy.name,
                onSelected: (_) => ref
                    .read(userFiltersProvider.notifier)
                    .setOrderBy(UserOrderBy.name),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Edad'),
                selected: filters.orderBy == UserOrderBy.age,
                onSelected: (_) => ref
                    .read(userFiltersProvider.notifier)
                    .setOrderBy(UserOrderBy.age),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Botones
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(userFiltersProvider.notifier).reset();
                    Navigator.pop(context);
                  },
                  child: const Text('Restablecer'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
