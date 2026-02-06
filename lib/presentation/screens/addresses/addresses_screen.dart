import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/address_controller.dart';
import '../../../domain/entities/address.dart';
import '../../../core/theme/app_colors.dart';
import 'address_form_screen.dart';

class AddressesScreen extends ConsumerWidget {
  final String userId;

  const AddressesScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addressControllerProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Mis Direcciones',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddressFormScreen(userId: userId),
            ),
          );
        },
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Agregar'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverse,
        elevation: 2,
      ),
      body: state.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => _ErrorState(message: e.toString()),
        data: (addresses) {
          if (addresses.isEmpty) {
            return _EmptyState(userId: userId);
          }

          // Ordenar: principales primero
          final sortedAddresses = [...addresses]
            ..sort((a, b) => b.isPrimary ? 1 : 0);

          return _AddressesList(addresses: sortedAddresses, userId: userId);
        },
      ),
    );
  }
}

class _AddressesList extends ConsumerStatefulWidget {
  final List<Address> addresses;
  final String userId;

  const _AddressesList({required this.addresses, required this.userId});

  @override
  ConsumerState<_AddressesList> createState() => _AddressesListState();
}

class _AddressesListState extends ConsumerState<_AddressesList> {
  String? _expandedAddressId;

  void _toggleExpanded(String addressId) {
    setState(() {
      _expandedAddressId = _expandedAddressId == addressId ? null : addressId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: widget.addresses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) {
            final address = widget.addresses[index];
            final isExpanded = _expandedAddressId == address.id;

            return _AddressListItem(
              address: address,
              isExpanded: isExpanded,
              onToggle: () => _toggleExpanded(address.id),
              onEdit: () => _openEditForm(context, address),
              onDelete: () => _deleteAddress(ref, address),
              onSetPrimary: () => _setPrimary(ref, address),
            );
          },
        ),
      ),
    );
  }

  void _openEditForm(BuildContext context, Address address) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddressFormScreen(userId: widget.userId, address: address),
      ),
    );
  }

  Future<void> _deleteAddress(WidgetRef ref, Address address) async {
    await ref
        .read(addressControllerProvider(widget.userId).notifier)
        .deleteAddress(address.id);
    // Colapsar si estaba expandido
    if (_expandedAddressId == address.id) {
      setState(() => _expandedAddressId = null);
    }
  }

  Future<void> _setPrimary(WidgetRef ref, Address address) async {
    await ref
        .read(addressControllerProvider(widget.userId).notifier)
        .setPrimaryAddress(address);
  }
}



class _AddressListItem extends StatelessWidget {
  final Address address;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetPrimary;

  const _AddressListItem({
    required this.address,
    required this.isExpanded,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = _getLabelColor();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? labelColor.withOpacity(0.4)
              : AppColors.border.withOpacity(0.6),
          width: isExpanded ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Etiqueta (Casa / Trabajo / Otro)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: labelColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getLabelIcon(), size: 14, color: labelColor),
                        const SizedBox(width: 6),
                        Text(
                          address.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: labelColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Indicador "Principal"
                  if (address.isPrimary)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.starGold.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: AppColors.starGold,
                      ),
                    ),
                ],
              ),
            ),
            // ═══════════════════════════════════════════════════════════
            // ║  DIRECCIÓN CORTA: Siempre visible                        ║
            // ═══════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                address.street,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // ═══════════════════════════════════════════════════════════
            // ║  DETALLE EXPANDIBLE                                      ║
            // ═══════════════════════════════════════════════════════════
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: isExpanded
                  ? Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: AppColors.border.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                      ),
                      child: _AddressDetailsSection(
                        address: address,
                        onEdit: onEdit,
                        onDelete: onDelete,
                        onSetPrimary: onSetPrimary,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLabelColor() {
    final label = address.label.toLowerCase();
    if (label == 'casa') return AppColors.primary;
    if (label == 'trabajo') return AppColors.secondary;
    return AppColors.textSecondary;
  }

  IconData _getLabelIcon() {
    final label = address.label.toLowerCase();
    if (label == 'casa') return Icons.home_outlined;
    if (label == 'trabajo') return Icons.work_outline;
    return Icons.location_on_outlined;
  }
}

// ════════════════════════════════════════════════════════════════════════════════════════════
// ║                                ADDRESS DETAILS SECTION                                     ║
// ════════════════════════════════════════════════════════════════════════════════════════════

class _AddressDetailsSection extends StatelessWidget {
  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetPrimary;

  const _AddressDetailsSection({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══════════════════════════════════════════════════════════
          // ║  INFORMACIÓN COMPLETA                                      ║
          // ═══════════════════════════════════════════════════════════
          if (address.neighborhood.isNotEmpty) ...[
            _DetailRow(
              icon: Icons.map_outlined,
              label: 'Colonia / Barrio',
              value: address.neighborhood,
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: _DetailRow(
                  icon: Icons.domain_outlined,
                  label: 'Estado',
                  value: address.state,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _DetailRow(
                  icon: Icons.location_city_outlined,
                  label: 'Ciudad',
                  value: address.city,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.markunread_mailbox_outlined,
            label: 'Código Postal',
            value: address.postalCode,
          ),
          const SizedBox(height: 16),
          // ═══════════════════════════════════════════════════════════
          // ║  ACCIONES                                                 ║
          // ═══════════════════════════════════════════════════════════
          _ActionsRow(
            address: address,
            onEdit: onEdit,
            onDelete: onDelete,
            onSetPrimary: onSetPrimary,
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════════════════
// ║                                DETAIL ROW                                                  ║
// ════════════════════════════════════════════════════════════════════════════════════════════

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textTertiary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════════════════
// ║                                ACTIONS ROW                                                 ║
// ════════════════════════════════════════════════════════════════════════════════════════════

class _ActionsRow extends StatelessWidget {
  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetPrimary;

  const _ActionsRow({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Editar
        Expanded(
          child: _ActionButton(
            icon: Icons.edit_outlined,
            label: 'Editar',
            onTap: onEdit,
          ),
        ),
        const SizedBox(width: 8),
        // Marcar principal (si no es principal)
        if (!address.isPrimary) ...[
          Expanded(
            child: _ActionButton(
              icon: Icons.star_border,
              label: 'Principal',
              onTap: onSetPrimary,
            ),
          ),
          const SizedBox(width: 8),
        ],
        // Eliminar
        Expanded(
          child: _ActionButton(
            icon: Icons.delete_outline,
            label: 'Eliminar',
            onTap: onDelete,
            isDestructive: true,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════════════════
// ║                                ACTION BUTTON                                               ║
// ════════════════════════════════════════════════════════════════════════════════════════════

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDestructive ? () => _confirmDelete(context) : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withOpacity(0.08)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isDestructive ? AppColors.error : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDestructive
                    ? AppColors.error
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar dirección'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta dirección?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onTap();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textInverse,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════════════════
// ║                                EMPTY STATE                                                ║
// ════════════════════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final String userId;

  const _EmptyState({required this.userId});

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
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.location_off,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Sin direcciones',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Agrega tu primera dirección\npara comenzar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddressFormScreen(userId: userId),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Agregar Dirección'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
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

// ════════════════════════════════════════════════════════════════════════════════════════════
// ║                                ERROR STATE                                                ║
// ════════════════════════════════════════════════════════════════════════════════════════════

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
