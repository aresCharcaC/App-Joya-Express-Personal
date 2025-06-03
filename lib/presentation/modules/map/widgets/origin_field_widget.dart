import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../viewmodels/map_viewmodel.dart';

/// Widget del campo origen (solo lectura)
class OriginFieldWidget extends StatelessWidget {
  const OriginFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MapViewModel>(
      builder: (context, mapViewModel, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF505050), // Gris más claro
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Pin blanco
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  mapViewModel.hasPickupLocation
                      ? (mapViewModel.pickupLocation!.address ??
                          'Ubicación seleccionada')
                      : 'Sin ubicación de origen',
                  style: AppTextStyles.interBody.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
