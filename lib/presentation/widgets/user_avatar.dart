import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Avatar con inicial del usuario
/// Usa gradientes modernas para un look más vibrante
class UserAvatar extends StatelessWidget {
  final String name;
  final double size;

  const UserAvatar({super.key, required this.name, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name);
    final gradientIndex = name.length % AppColors.avatarGradients.length;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.avatarGradients[gradientIndex],
            AppColors.avatarGradients[(gradientIndex + 1) %
                AppColors.avatarGradients.length],
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
            color: AppColors.textInverse,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }
}
