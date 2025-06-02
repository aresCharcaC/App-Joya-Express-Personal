import 'package:flutter/material.dart';
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_strings.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';
/**
 * ConfirmationDialog
 * ------------------
 * Diálogo reutilizable para confirmar acciones, como cerrar sesión.
 * Permite personalizar título, mensaje y botones.
 * Devuelve true si el usuario confirma, false si cancela.
 */
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm; // Acción a ejecutar al confirmar
  final VoidCallback? onCancel;
  final Color? confirmButtonColor;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
    this.onCancel,
    this.confirmButtonColor,
  });

  /// Método estático para mostrar el diálogo de logout fácilmente

  static Future<bool?> showLogoutDialog(BuildContext context, VoidCallback onConfirm) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,// El usuario no puede cerrar tocando fuera
      builder: (context) => ConfirmationDialog(
        title: AppStrings.logoutTitle,
        message: AppStrings.logoutMessage,
        confirmText: AppStrings.logoutConfirm,
        cancelText: AppStrings.logoutCancel,
        confirmButtonColor: AppColors.primary,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        title,
        style: AppTextStyles.poppinsHeading3,
        textAlign: TextAlign.center,
      ),
      content: Text(
        message,
        style: AppTextStyles.interBody,
        textAlign: TextAlign.center,
      ),
      actions: [
        Row(
          children: [
            // Botón de cancelar
            Expanded(
              child: TextButton(
                onPressed: onCancel ?? () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
                child: Text(
                  cancelText,
                  style: AppTextStyles.interBody.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Botón de confirmar
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);// Cierra el diálogo y devuelve true
                  onConfirm();// Ejecuta la acción de confirmación
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: confirmButtonColor ?? AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  confirmText,
                  style: AppTextStyles.poppinsButton,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}