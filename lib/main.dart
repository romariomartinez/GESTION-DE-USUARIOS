import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/models/user_model.dart';
import 'data/models/address_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // INIT HIVE
  await Hive.initFlutter();

  // REGISTER ADAPTERS (solo una vez)
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(UserModelAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(AddressModelAdapter());
  }

  // OPEN BOXES (CRÍTICO)
  await Hive.openBox<UserModel>('users');
  await Hive.openBox<AddressModel>('addresses');

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
