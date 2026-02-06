import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/validators/name_validator.dart';
import '../../../core/validators/email_validator.dart';
import '../../../core/validators/birthdate_validator.dart';
import '../../../core/validators/phone_validator.dart';
import '../../../core/utils/id_generator.dart';
import '../../../domain/entities/user.dart';
import '../../controllers/user_form_controller.dart';
import '../../widgets/primary_button.dart';


class UserFormScreen extends ConsumerStatefulWidget {
  final User? user;

  const UserFormScreen({super.key, this.user});

  @override
  ConsumerState<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends ConsumerState<UserFormScreen> {
  // Controllers con lifecycle management
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  String _selectedCountryCode = '+57';
  DateTime? _birthDate;

  // Errores para validación en tiempo real
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _birthDateError;
  String? _phoneError;

  bool get isEdit => widget.user != null;

  // Constantes para límites
  static const _nameMaxLength = 50;

  // Códigos de países comunes
  static const _countryCodes = [
    {'code': '+1', 'country': 'EE.UU.'},
    {'code': '+52', 'country': 'México'},
    {'code': '+54', 'country': 'Argentina'},
    {'code': '+55', 'country': 'Brasil'},
    {'code': '+56', 'country': 'Chile'},
    {'code': '+57', 'country': 'Colombia'},
    {'code': '+58', 'country': 'Venezuela'},
    {'code': '+51', 'country': 'Perú'},
    {'code': '+593', 'country': 'Ecuador'},
    {'code': '+507', 'country': 'Panamá'},
    {'code': '+34', 'country': 'España'},
  ];

  @override
  void initState() {
    super.initState();

    _firstNameCtrl = TextEditingController(text: widget.user?.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: widget.user?.lastName ?? '');
    _emailCtrl = TextEditingController(text: widget.user?.email ?? '');
    _phoneCtrl = TextEditingController(
      text: _extractPhoneNumber(widget.user?.phone ?? ''),
    );
    _birthDate = widget.user?.birthDate;

    // Listener para validación en tiempo real en campos de texto
    _firstNameCtrl.addListener(_validateAll);
    _lastNameCtrl.addListener(_validateAll);
    _emailCtrl.addListener(_validateAll);
    _phoneCtrl.addListener(_validateAll);
  }

  String _extractPhoneNumber(String fullPhone) {
    // Extraer solo el número sin el código de país
    for (var cc in _countryCodes) {
      if (fullPhone.startsWith(cc['code']!)) {
        return fullPhone.substring(cc['code']!.length).trim();
      }
    }
    return fullPhone;
  }

  @override
  void dispose() {
    _firstNameCtrl.removeListener(_validateAll);
    _lastNameCtrl.removeListener(_validateAll);
    _emailCtrl.removeListener(_validateAll);
    _phoneCtrl.removeListener(_validateAll);
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _validateAll() => setState(() {
    _firstNameError = validateName(_firstNameCtrl.text);
    _lastNameError = validateName(_lastNameCtrl.text);
    _emailError = validateEmail(_emailCtrl.text);
    _birthDateError = validateBirthDate(_birthDate);

    final fullPhone = PhoneValidator.toE164(
      _selectedCountryCode,
      _phoneCtrl.text.trim(),
    );
    _phoneError = PhoneValidator.validate(
      phoneNumber: fullPhone,
      isoCode: _getIsoCode(_selectedCountryCode),
    );
  });

  String _getIsoCode(String countryCode) {
    // Mapeo simple de códigos a códigos ISO
    final map = {
      '+1': 'US',
      '+52': 'MX',
      '+54': 'AR',
      '+55': 'BR',
      '+56': 'CL',
      '+57': 'CO',
      '+58': 'VE',
      '+51': 'PE',
      '+593': 'EC',
      '+507': 'PA',
      '+34': 'ES',
    };
    return map[countryCode] ?? 'US';
  }

  bool get _isFormValid =>
      _firstNameError == null &&
      _lastNameError == null &&
      _emailError == null &&
      _birthDateError == null &&
      _birthDate != null &&
      _phoneError == null &&
      _firstNameCtrl.text.isNotEmpty &&
      _lastNameCtrl.text.isNotEmpty &&
      _emailCtrl.text.isNotEmpty &&
      _phoneCtrl.text.isNotEmpty;

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() => _birthDate = picked);
      _validateAll();
    }
  }

  Future<void> _submit() async {
    if (!_isFormValid) return;

    final fullPhone = '$_selectedCountryCode${_phoneCtrl.text.trim()}';

    final user = User(
      id: widget.user?.id ?? IdGenerator.generate(),
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      birthDate: _birthDate!,
      email: _emailCtrl.text.trim(),
      phone: fullPhone,
    );

    final notifier = ref.read(userFormControllerProvider.notifier);

    if (isEdit) {
      await notifier.updateUser(user);
    } else {
      await notifier.createUser(user);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userFormControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Crear Usuario'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 600,
                    minHeight: constraints.maxHeight - 32,
                  ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeaderSection(),
                          const SizedBox(height: 24),
                          _buildPersonalInfoSection(),
                          const SizedBox(height: 24),
                          _buildContactSection(),
                          const SizedBox(height: 32),
                          _buildSubmitButton(state.isLoading),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEdit ? 'Editar Usuario' : 'Nuevo Usuario',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isEdit
              ? 'Actualiza la información del usuario'
              : 'Completa los datos para registrar un nuevo usuario',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
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
                'Información Personal',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildNameFields(),
        const SizedBox(height: 16),
        _buildBirthDateField(),
      ],
    );
  }

  Widget _buildNameFields() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _firstNameCtrl,
            label: 'Nombre',
            error: _firstNameError,
            maxLength: _nameMaxLength,
            hint: 'Ingresa nombre',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTextField(
            controller: _lastNameCtrl,
            label: 'Apellido',
            error: _lastNameError,
            maxLength: _nameMaxLength,
            hint: 'Ingresa apellido',
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? error,
    required int maxLength,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLength: maxLength,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '${controller.text.length}/$maxLength',
            counterStyle: TextStyle(
              fontSize: 12,
              color: controller.text.length >= maxLength
                  ? AppColors.error
                  : AppColors.textTertiary,
            ),
            errorText: error,
            errorMaxLines: 2,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildBirthDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha de nacimiento',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: _selectBirthDate,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: 'Selecciona fecha',
              helperText: _birthDate == null
                  ? null
                  : 'Debe ser mayor de 18 años',
              helperStyle: TextStyle(
                color: _birthDateError != null
                    ? AppColors.error
                    : AppColors.textSecondary,
              ),
              errorText: _birthDateError,
              errorMaxLines: 2,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.error),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: _birthDate != null
                      ? AppColors.primary
                      : AppColors.textTertiary,
                ),
                const SizedBox(width: 12),
                Text(
                  _birthDate == null
                      ? 'Selecciona fecha'
                      : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: _birthDate != null
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Contacto',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildEmailField(),
        const SizedBox(height: 16),
        _buildPhoneField(),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: 'correo@ejemplo.com',
            prefixIcon: const Icon(
              Icons.email_outlined,
              size: 20,
              color: AppColors.textTertiary,
            ),
            errorText: _emailError,
            errorMaxLines: 2,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Teléfono',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selector de código de país
            Container(
              width: 115,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedCountryCode,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.arrow_drop_down, size: 20),
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
                items: _countryCodes.map((country) {
                  return DropdownMenuItem<String>(
                    value: country['code'],
                    child: Text(
                      country['code']!,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCountryCode = value!;
                  });
                  _validateAll();
                },
              ),
            ),
            const SizedBox(width: 12),
            // Campo de número de teléfono
            Expanded(
              child: TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  hintText: 'Número de teléfono',
                  errorText: _phoneError,
                  errorMaxLines: 2,
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.error),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.error,
                      width: 2,
                    ),
                  ),
                ),
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
                onChanged: (_) => _validateAll(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return PrimaryButton(
      label: isEdit ? 'Actualizar Usuario' : 'Crear Usuario',
      isLoading: isLoading,
      onPressed: _isFormValid ? _submit : null,
    );
  }
}
