// lib/presentation/modules/auth/Driver/widgets/compact_passenger_info.dart
import 'package:flutter/material.dart';
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';

class CompactPassengerInfo extends StatelessWidget {
  final dynamic request;

  const CompactPassengerInfo({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 🖼️ FOTO DEL PASAJERO
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child:
                request.foto?.isNotEmpty == true
                    ? ClipOval(
                      child: Image.network(
                        request.foto!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildAvatarFallback(),
                      ),
                    )
                    : _buildAvatarFallback(),
          ),

          const SizedBox(width: 16),

          // 📝 INFO DEL PASAJERO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre + Rating
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        request.nombre ?? 'Sin nombre',
                        style: AppTextStyles.poppinsHeading3.copyWith(
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // ⭐ RATING
                    if (request.rating != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            request.rating!.toStringAsFixed(1),
                            style: AppTextStyles.interBodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // 📍 ORIGEN
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.black87,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.direccion ?? 'Origen no especificado',
                        style: AppTextStyles.interBodySmall.copyWith(
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // 🚩 DESTINO
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.destinoDireccion ?? 'Destino no especificado',
                        style: AppTextStyles.interBodySmall.copyWith(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // 📏 DISTANCIA TOTAL
                if (request.distanciaKm != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${request.distanciaKm!.toStringAsFixed(1)} km total',
                      style: AppTextStyles.interBodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Center(
      child: Text(
        request.nombre?.isNotEmpty == true
            ? request.nombre![0].toUpperCase()
            : '?',
        style: AppTextStyles.poppinsButton.copyWith(
          fontSize: 20,
          color: AppColors.white,
        ),
      ),
    );
  }
}
