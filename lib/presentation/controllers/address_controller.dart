import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../domain/entities/address.dart';
import '../../domain/usecases/addresses/add_address.dart';
import '../../domain/usecases/addresses/update_address.dart';
import '../../domain/usecases/addresses/delete_address.dart';
import '../../domain/usecases/addresses/set_primary_address.dart';
import './providers.dart';

final _logger = Logger('AddressController');

/// Controller provider (por usuario)
final addressControllerProvider =
    AsyncNotifierProviderFamily<AddressController, List<Address>, String>(
      AddressController.new,
    );

class AddressController extends FamilyAsyncNotifier<List<Address>, String> {
  @override
  Future<List<Address>> build(String arg) async {
    // arg es el userId passado al provider family
    return _loadAddresses(arg);
  }

  Future<List<Address>> _loadAddresses(String userId) async {
    try {
      return await ref.read(addressRepositoryProvider).getByUser(userId);
    } catch (e, stack) {
      _logger.severe('Error cargando direcciones', e, stack);
      rethrow;
    }
  }

  /// Agregar dirección
  Future<void> addAddress(Address address) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      try {
        await AddAddress(
          ref.read(addressRepositoryProvider),
        ).call(userId: arg, address: address);

        // Recargar direcciones después de agregar
        final addresses = await _loadAddresses(arg);
        showError(ref, ''); // Limpiar errores previos
        return addresses;
      } catch (e, stack) {
        _logger.severe('Error agregando dirección', e, stack);
        showError(ref, 'No se pudo agregar la dirección. Verifica los datos.');
        rethrow;
      }
    });
  }

  /// Actualizar dirección
  Future<void> updateAddress(Address address) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      try {
        await UpdateAddress(
          ref.read(addressRepositoryProvider),
        ).call(userId: arg, address: address);

        // Recargar direcciones después de actualizar
        final addresses = await _loadAddresses(arg);
        showError(ref, ''); // Limpiar errores previos
        return addresses;
      } catch (e, stack) {
        _logger.severe('Error actualizando dirección', e, stack);
        showError(ref, 'No se pudo actualizar la dirección. Intenta de nuevo.');
        rethrow;
      }
    });
  }

 
  Future<void> deleteAddress(String addressId) async {
    state = const AsyncLoading(); 

    state = await AsyncValue.guard(() async {
      try {
        await DeleteAddress(
          ref.read(addressRepositoryProvider),
        ).call(userId: arg, addressId: addressId);

        
        final addresses = await _loadAddresses(arg);
        showError(ref, ''); // Limpiar errores previos
        return addresses;
      } catch (e, stack) {
        _logger.severe('Error eliminando dirección', e, stack);
        showError(ref, 'No se pudo eliminar la dirección. Intenta de nuevo.');
        rethrow;
      }
    });
  }

  /// Establecer como dirección principal
  Future<void> setPrimaryAddress(Address address) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      try {
        await SetPrimaryAddress(
          ref.read(addressRepositoryProvider),
        ).call(userId: arg, address: address);

        
        final addresses = await _loadAddresses(arg);
        showError(ref, ''); // Limpiar errores previos
        return addresses;
      } catch (e, stack) {
        _logger.severe('Error estableciendo dirección principal', e, stack);
        showError(
          ref,
          'No se pudo establecer como principal. Intenta de nuevo.',
        );
        rethrow;
      }
    });
  }

  /// Recargar direcciones manualmente
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadAddresses(arg));
  }
}
