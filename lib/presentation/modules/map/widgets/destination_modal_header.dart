import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Header minimalista para el modal de destino (SIN botón X)
class DestinationModalHeader extends StatelessWidget {
  const DestinationModalHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D2D), // Color oscuro
      ),
      child: Center(
        child: Text(
          'Seleccionar destino',
          style: AppTextStyles.interBody.copyWith(
            color: AppColors.white.withOpacity(0.8),
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
