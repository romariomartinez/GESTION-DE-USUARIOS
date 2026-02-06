import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/id_generator.dart';
import '../../../core/validators/address_validator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/address.dart';
import '../../controllers/address_controller.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class AddressFormScreen extends ConsumerStatefulWidget {
  final String userId;
  final Address? address;

  const AddressFormScreen({super.key, required this.userId, this.address});

  @override
  ConsumerState<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends ConsumerState<AddressFormScreen> {
  late final TextEditingController _streetCtrl;
  late final TextEditingController _neighborhoodCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _postalCtrl;
  late final TextEditingController _customLabelCtrl;

  static const _labelOptions = ['Casa', 'Trabajo', 'Otro'];
  String _selectedLabel = 'Casa';
  bool _isPrimary = false;

  // Errores para validación en tiempo real
  String? _streetError;
  String? _neighborhoodError;
  String? _cityError;
  String? _stateError;
  String? _postalError;
  String? _customLabelError;

  bool get isEdit => widget.address != null;

  @override
  void initState() {
    super.initState();

    _streetCtrl = TextEditingController(text: widget.address?.street ?? '');
    _neighborhoodCtrl = TextEditingController(
      text: widget.address?.neighborhood ?? '',
    );
    _cityCtrl = TextEditingController(text: widget.address?.city ?? '');
    _stateCtrl = TextEditingController(text: widget.address?.state ?? '');
    _postalCtrl = TextEditingController(text: widget.address?.postalCode ?? '');

    _selectedLabel = widget.address?.label ?? 'Casa';
    _isPrimary = widget.address?.isPrimary ?? false;

    // Initialize custom label controller for "Otro" option
    _customLabelCtrl = TextEditingController(
      text: _selectedLabel == 'Otro' ? widget.address?.label ?? '' : '',
    );

    // Agregar listeners para validación en tiempo real
    _streetCtrl.addListener(_validateStreet);
    _neighborhoodCtrl.addListener(_validateNeighborhood);
    _cityCtrl.addListener(_validateCity);
    _stateCtrl.addListener(_validateState);
    _postalCtrl.addListener(_validatePostalCode);
    _customLabelCtrl.addListener(_validateCustomLabel);
  }

  void _validateStreet() {
    setState(() {
      _streetError = validateStreet(_streetCtrl.text);
    });
  }

  void _validateNeighborhood() {
    setState(() {
      _neighborhoodError = validateNeighborhood(_neighborhoodCtrl.text);
    });
  }

  void _validateCity() {
    setState(() {
      _cityError = validateCity(_cityCtrl.text);
    });
  }

  void _validateState() {
    setState(() {
      _stateError = validateState(_stateCtrl.text);
    });
  }

  void _validatePostalCode() {
    setState(() {
      _postalError = validatePostalCode(_postalCtrl.text);
    });
  }

  void _validateCustomLabel() {
    setState(() {
      if (_selectedLabel == 'Otro') {
        _customLabelError = _customLabelCtrl.text.trim().isEmpty
            ? 'Ingresa una etiqueta personalizada'
            : null;
      } else {
        _customLabelError = null;
      }
    });
  }

  void _onLabelChanged(String newLabel) {
    setState(() {
      _selectedLabel = newLabel;
      // Clear error when changing label
      _customLabelError = null;
    });
  }

  /// Get final label value (custom or predefined)
  String get _finalLabel {
    if (_selectedLabel == 'Otro') {
      return _customLabelCtrl.text.trim().isNotEmpty
          ? _customLabelCtrl.text.trim()
          : 'Otro';
    }
    return _selectedLabel;
  }

  bool _validateAll() {
    _validateStreet();
    _validateNeighborhood();
    _validateCity();
    _validateState();
    _validatePostalCode();
    _validateCustomLabel();

    return _streetError == null &&
        _neighborhoodError == null &&
        _cityError == null &&
        _stateError == null &&
        _postalError == null &&
        _customLabelError == null;
  }

  @override
  void dispose() {
    _streetCtrl.removeListener(_validateStreet);
    _neighborhoodCtrl.removeListener(_validateNeighborhood);
    _cityCtrl.removeListener(_validateCity);
    _stateCtrl.removeListener(_validateState);
    _postalCtrl.removeListener(_validatePostalCode);
    _customLabelCtrl.removeListener(_validateCustomLabel);

    _streetCtrl.dispose();
    _neighborhoodCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _postalCtrl.dispose();
    _customLabelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addressControllerProvider(widget.userId));
    final isLoading = state.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          isEdit ? 'Editar Dirección' : 'Nueva Dirección',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sección de información
                        _buildSectionHeader(
                          Icons.location_on,
                          'Información de la Dirección',
                        ),
                        const SizedBox(height: 16),

                        AppTextField(
                          label: 'Calle y Número',
                          controller: _streetCtrl,
                          errorText: _streetError,
                          isRequired: true,
                          prefixIcon: const Icon(Icons.home_outlined, size: 20),
                          hintText: 'Ej: Av. Principal 123',
                        ),
                        const SizedBox(height: 16),

                        AppTextField(
                          label: 'Colonia/Barrio',
                          controller: _neighborhoodCtrl,
                          errorText: _neighborhoodError,
                          prefixIcon: const Icon(
                            Icons.location_city_outlined,
                            size: 20,
                          ),
                          hintText: 'Ej: Centro',
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'Ciudad',
                                controller: _cityCtrl,
                                errorText: _cityError,
                                isRequired: true,
                                prefixIcon: const Icon(
                                  Icons.map_outlined,
                                  size: 20,
                                ),
                                hintText: 'Ciudad',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTextField(
                                label: 'Estado',
                                controller: _stateCtrl,
                                errorText: _stateError,
                                isRequired: true,
                                prefixIcon: const Icon(
                                  Icons.domain_outlined,
                                  size: 20,
                                ),
                                hintText: 'Estado',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        AppTextField(
                          label: 'Código Postal',
                          controller: _postalCtrl,
                          errorText: _postalError,
                          isRequired: true,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(
                            Icons.markunread_mailbox_outlined,
                            size: 20,
                          ),
                          hintText: 'CP',
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Sección de etiqueta
                        _buildSectionHeader(Icons.label, 'Etiqueta'),
                        const SizedBox(height: 12),
                        _buildLabelSelector(),
                        const SizedBox(height: 24),

                        // Sección de principal
                        _buildSectionHeader(Icons.star, 'Dirección Principal'),
                        const SizedBox(height: 12),
                        _buildPrimarySwitch(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Botón de guardar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: isEdit
                          ? 'Actualizar Dirección'
                          : 'Guardar Dirección',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _submitForm,
                      icon: Icon(isEdit ? Icons.check : Icons.save_outlined),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildLabelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: _labelOptions.map((label) {
              final isSelected = _selectedLabel == label;
              final color = _getLabelColor(label);

              return Expanded(
                child: GestureDetector(
                  onTap: () => _onLabelChanged(label),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? color : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getLabelIcon(label),
                          size: 18,
                          color: isSelected ? AppColors.textInverse : color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.textInverse : color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Campo adicional para etiqueta personalizada
        if (_selectedLabel == 'Otro') ...[
          const SizedBox(height: 12),
          AppTextField(
            label: 'Especifica la etiqueta',
            controller: _customLabelCtrl,
            errorText: _customLabelError,
            isRequired: true,
            prefixIcon: const Icon(Icons.edit_outlined, size: 20),
            hintText: 'Ej: Casa de mi mamá',
          ),
        ],
      ],
    );
  }

  Widget _buildPrimarySwitch() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile.adaptive(
        value: _isPrimary,
        onChanged: (value) => setState(() => _isPrimary = value),
        title: Row(
          children: [
            const Icon(Icons.star_border, size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Establecer como dirección principal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        activeColor: AppColors.primary,
        activeTrackColor: AppColors.primaryLight.withOpacity(0.5),
      ),
    );
  }

  void _submitForm() {
    if (!_validateAll()) {
      // Mostrar mensaje de error si hay campos inválidos
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Por favor, corrige los errores en el formulario',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    _saveAddress();
  }

  Future<void> _saveAddress() async {
    final address = Address(
      id: widget.address?.id ?? IdGenerator.generate(),
      userId: widget.userId,
      street: _streetCtrl.text.trim(),
      neighborhood: _neighborhoodCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      postalCode: _postalCtrl.text.trim(),
      label: _finalLabel, // Use computed final label
      isPrimary: _isPrimary,
    );

    final notifier = ref.read(
      addressControllerProvider(widget.userId).notifier,
    );

    if (isEdit) {
      await notifier.updateAddress(address);
    } else {
      await notifier.addAddress(address);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  Color _getLabelColor(String label) {
    switch (label) {
      case 'Casa':
        return AppColors.primary;
      case 'Trabajo':
        return AppColors.secondary;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getLabelIcon(String label) {
    switch (label) {
      case 'Casa':
        return Icons.home;
      case 'Trabajo':
        return Icons.work;
      default:
        return Icons.location_on;
    }
  }
}
