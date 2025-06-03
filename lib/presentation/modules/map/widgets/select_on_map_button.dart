import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Botón limpio para seleccionar destino en el mapa (SIN recuadro)
class SelectOnMapButton extends StatelessWidget {
  final VoidCallback onTap;

  const SelectOnMapButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              // Icono simbólico azul
              Icon(Icons.map_outlined, color: AppColors.info, size: 20),

              const SizedBox(width: 8),

              // Texto azul simple
              Text(
                'Seleccionar en el mapa',
                style: AppTextStyles.interBody.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
