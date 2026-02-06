import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/entities/address.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../controllers/user_detail_controller.dart';
import '../../controllers/address_controller.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/primary_button.dart';
import '../addresses/addresses_screen.dart';

/// Pantalla de perfil de usuario mobile-first.
///
/// Diseño profesional similar a apps bancarias/gestión:
/// - Header con avatar, nombre y email
/// - Cards bien definidas con secciones claras
/// - Iconografía sutil para escaneo rápido
/// - CTA fixed-bottom para acción principal
class UserDetailScreen extends ConsumerWidget {
  final String userId;

  const UserDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userDetailControllerProvider(userId));
    final addressesState = ref.watch(addressControllerProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Perfil')),
      body: userState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (user) {
          if (user == null) {
            return _buildNotFoundState(context);
          }

          return _buildProfileContent(context, user, addressesState);
        },
      ),
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            'Usuario no encontrado',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    User user,
    AsyncValue<List<Address>> addressesState,
  ) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(user),
                const SizedBox(height: 24),
                _buildPersonalInfoCard(user),
                const SizedBox(height: 16),
                _buildPrimaryAddressCard(addressesState),
                const SizedBox(height: 16),
                _buildAdditionalAddressesSection(addressesState),
                const SizedBox(height: 24),
                _buildManageAddressesButton(context, user.id),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(User user) {
    return Column(
      children: [
        UserAvatar(name: user.fullName, size: 96),
        const SizedBox(height: 16),
        Text(
          user.fullName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoCard(User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardTitle('Información Personal'),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.badge_outlined,
              label: 'Nombre completo',
              value: user.fullName,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.cake_outlined,
              label: 'Fecha de nacimiento',
              value:
                  '${user.birthDate.toLocal().toString().split(' ')[0]} (${user.age} años)',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: user.email,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.phone_outlined,
              label: 'Teléfono',
              value: user.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryAddressCard(AsyncValue<List<Address>> addressesState) {
    return addressesState.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (addresses) {
        final primaryAddress = addresses.firstWhere(
          (a) => a.isPrimary,
          orElse: () => addresses.isNotEmpty
              ? addresses.first
              : Address(
                  id: '',
                  userId: '',
                  street: '',
                  neighborhood: '',
                  city: '',
                  state: '',
                  postalCode: '',
                  label: '',
                  isPrimary: false,
                ),
        );

        if (addresses.isEmpty || primaryAddress.id.isEmpty) {
          return const SizedBox.shrink();
        }

        return _PrimaryAddressCard(address: primaryAddress);
      },
    );
  }

  Widget _buildAdditionalAddressesSection(
    AsyncValue<List<Address>> addressesState,
  ) {
    return addressesState.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (addresses) {
        final additionalAddresses = addresses
            .where((a) => !a.isPrimary)
            .toList();

        if (additionalAddresses.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Direcciones Adicionales',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ...additionalAddresses.map(
              (address) => _CompactAddressCard(address: address),
            ),
          ],
        );
      },
    );
  }

  Color _getLabelColor(String label) {
    final lower = label.toLowerCase();
    if (lower == 'casa') return AppColors.primary;
    if (lower == 'trabajo') return AppColors.secondary;
    return AppColors.textSecondary;
  }

  IconData _getLabelIcon(String label) {
    final lower = label.toLowerCase();
    if (lower == 'casa') return Icons.home_outlined;
    if (lower == 'trabajo') return Icons.work_outline;
    return Icons.location_on_outlined;
  }

  Widget _buildCardTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textTertiary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressContent(Address address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                address.label.isNotEmpty ? address.label : 'Casa',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildAddressLine(Icons.location_on_outlined, address.street),
        if (address.neighborhood.isNotEmpty)
          _buildAddressLine(Icons.map_outlined, address.neighborhood),
        _buildAddressLine(
          Icons.location_city_outlined,
          '${address.city}, ${address.state} ${address.postalCode}',
        ),
      ],
    );
  }

  Widget _buildAddressLine(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageAddressesButton(BuildContext context, String userId) {
    return PrimaryButton(
      label: 'Gestionar Direcciones',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddressesScreen(userId: userId)),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════════════════
// ║                          COMPACT ADDRESS CARD WIDGET                                    ║
// ════════════════════════════════════════════════════════════════════════════════════════════

class _CompactAddressCard extends StatelessWidget {
  final Address address;

  const _CompactAddressCard({required this.address});

  Color _getLabelColor(String label) {
    final lower = label.toLowerCase();
    if (lower == 'casa') return AppColors.primary;
    if (lower == 'trabajo') return AppColors.secondary;
    return AppColors.textSecondary;
  }

  IconData _getLabelIcon(String label) {
    final lower = label.toLowerCase();
    if (lower == 'casa') return Icons.home_outlined;
    if (lower == 'trabajo') return Icons.work_outline;
    return Icons.location_on_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final labelColor = _getLabelColor(address.label);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showAddressPopup(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: labelColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getLabelIcon(address.label),
                  size: 20,
                  color: labelColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.label.isNotEmpty ? address.label : 'Otro',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: labelColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      address.street,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.info_outline,
                size: 18,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddressPopup(BuildContext context) {
    final labelColor = _getLabelColor(address.label);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con etiqueta y botón cerrar
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: labelColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getLabelIcon(address.label),
                          size: 16,
                          color: labelColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          address.label.isNotEmpty ? address.label : 'Otro',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: labelColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Calle
              _buildPopupRow(
                Icons.location_on_outlined,
                'Calle',
                address.street,
              ),
              if (address.neighborhood.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildPopupRow(
                  Icons.map_outlined,
                  'Colonia / Barrio',
                  address.neighborhood,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildPopupRow(
                      Icons.domain_outlined,
                      'Estado',
                      address.state,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPopupRow(
                      Icons.location_city_outlined,
                      'Ciudad',
                      address.city,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildPopupRow(
                Icons.markunread_mailbox_outlined,
                'Código Postal',
                address.postalCode,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
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
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════════════════════════
// ║                          PRIMARY ADDRESS CARD WIDGET                                         ║
// ════════════════════════════════════════════════════════════════════════════════════════════════

class _PrimaryAddressCard extends StatelessWidget {
  final Address address;

  const _PrimaryAddressCard({required this.address});

  Color _getLabelColor(String label) {
    final lower = label.toLowerCase();
    if (lower == 'casa') return AppColors.primary;
    if (lower == 'trabajo') return AppColors.secondary;
    return AppColors.textSecondary;
  }

  IconData _getLabelIcon(String label) {
    final lower = label.toLowerCase();
    if (lower == 'casa') return Icons.home_outlined;
    if (lower == 'trabajo') return Icons.work_outline;
    return Icons.location_on_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final labelColor = _getLabelColor(address.label);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showAddressPopup(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con badge Principal
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.starGold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppColors.starGold,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Principal',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.starGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Contenido resumido
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: labelColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getLabelIcon(address.label),
                      size: 20,
                      color: labelColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address.label.isNotEmpty ? address.label : 'Casa',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: labelColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          address.street,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddressPopup(BuildContext context) {
    final labelColor = _getLabelColor(address.label);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con badge Principal
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.starGold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: AppColors.starGold,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Dirección Principal',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.starGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Calle
              _buildPopupRow(
                Icons.location_on_outlined,
                'Calle',
                address.street,
              ),
              if (address.neighborhood.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildPopupRow(
                  Icons.map_outlined,
                  'Colonia / Barrio',
                  address.neighborhood,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildPopupRow(
                      Icons.domain_outlined,
                      'Estado',
                      address.state,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPopupRow(
                      Icons.location_city_outlined,
                      'Ciudad',
                      address.city,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildPopupRow(
                Icons.markunread_mailbox_outlined,
                'Código Postal',
                address.postalCode,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
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
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
