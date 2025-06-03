import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../domain/entities/place_entity.dart';

/// Widget para cada item de sugerencia en la lista (versión oscura)
class LocationSuggestionItemDark extends StatelessWidget {
  final PlaceEntity place;
  final VoidCallback onTap;
  final bool showCategory;
  final bool showDistance;
  final String? distance;

  const LocationSuggestionItemDark({
    super.key,
    required this.place,
    required this.onTap,
    this.showCategory = true,
    this.showDistance = false,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF404040), // Gris oscuro
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF606060), width: 1),
        ),
        child: Row(
          children: [
            // Icono según categoría
            _buildCategoryIcon(),

            const SizedBox(width: 12),

            // Información del lugar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del lugar
                  Text(
                    place.name,
                    style: AppTextStyles.interBody.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2),

                  // Descripción o categoría
                  if (place.description != null || showCategory)
                    Text(
                      place.description ?? place.category,
                      style: AppTextStyles.interCaption.copyWith(
                        color: AppColors.white.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Distancia (si está disponible)
            if (showDistance && distance != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF505050),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  distance!,
                  style: AppTextStyles.interCaption.copyWith(
                    color: AppColors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],

            // Icono de lugar popular
            if (place.isPopular) ...[
              const SizedBox(width: 8),
              Icon(Icons.star, size: 16, color: AppColors.warning),
            ],

            // Flecha
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.white.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  /// Icono según la categoría del lugar
  Widget _buildCategoryIcon() {
    IconData iconData;
    Color iconColor;

    switch (place.category.toLowerCase()) {
      case 'turístico':
        iconData = Icons.camera_alt_outlined;
        iconColor = AppColors.primary;
        break;
      case 'comercial':
        iconData = Icons.shopping_bag_outlined;
        iconColor = AppColors.secondary;
        break;
      case 'educación':
        iconData = Icons.school_outlined;
        iconColor = AppColors.info;
        break;
      case 'transporte':
        iconData = Icons.directions_bus_outlined;
        iconColor = AppColors.warning;
        break;
      case 'mercado':
        iconData = Icons.store_outlined;
        iconColor = AppColors.success;
        break;
      case 'salud':
        iconData = Icons.local_hospital_outlined;
        iconColor = AppColors.error;
        break;
      case 'avenida':
        iconData = Icons.route_outlined;
        iconColor = AppColors.grey;
        break;
      case 'distrito':
        iconData = Icons.location_city_outlined;
        iconColor = AppColors.textSecondary;
        break;
      default:
        iconData = Icons.place_outlined;
        iconColor = AppColors.primary;
        break;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor, size: 18),
    );
  }
}
