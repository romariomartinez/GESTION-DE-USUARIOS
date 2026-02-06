import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/user_list/user_list_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const UserListScreen(),
    );
  }
}
