import 'package:flutter/material.dart';
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';

/// DrawerMenuItem
/// --------------
/// Widget reutilizable que representa un elemento del menú lateral (Drawer).
/// Muestra un ícono, un texto y ejecuta una acción al ser presionado.
/// Permite personalizar colores de ícono y texto.

class DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const DrawerMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.textPrimary,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTextStyles.interBody.copyWith(
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
      onTap: onTap,// Ejecuta la acción al presionar el elemento
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      splashColor: AppColors.primary.withOpacity(0.1),// Efecto visual al presionar
    );
  }
}