// lib/presentation/modules/auth/Driver/widgets/price_offer_buttons.dart
import 'package:flutter/material.dart';
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';

class PriceOfferButtons extends StatelessWidget {
  final double userRequestedPrice;
  final double distanceKm;
  final Future<void> Function(double) onOfferSelected;
  final bool isLoading;

  const PriceOfferButtons({
    super.key,
    required this.userRequestedPrice,
    required this.distanceKm,
    required this.onOfferSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // 🧮 CALCULAR PRECIO SUGERIDO
    final suggestedPrice = _calculateSuggestedPrice(distanceKm);
    final minusPrice = suggestedPrice - 0.5;
    final plusPrice = suggestedPrice + 0.5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Texto explicativo
          Text(
            'Usuario pidió: S/ ${userRequestedPrice.toStringAsFixed(2)}',
            style: AppTextStyles.interBodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 12),

          // BOTONES DE CONTRA-OFERTA
          Row(
            children: [
              // ➖ MENOS 0.50
              Expanded(
                child: _buildOfferButton(
                  price: minusPrice,
                  label: '-0.50',
                  isPrimary: false,
                  backgroundColor: AppColors.error.withOpacity(0.1),
                  textColor: AppColors.error,
                ),
              ),

              const SizedBox(width: 12),

              // 🎯 PRECIO SUGERIDO (DESTACADO)
              Expanded(
                flex: 2, // Más ancho que los otros
                child: _buildOfferButton(
                  price: suggestedPrice,
                  label: 'Precio Sugerido',
                  isPrimary: true,
                  backgroundColor: AppColors.primary,
                  textColor: AppColors.white,
                ),
              ),

              const SizedBox(width: 12),

              // ➕ MÁS 0.50
              Expanded(
                child: _buildOfferButton(
                  price: plusPrice,
                  label: '+0.50',
                  isPrimary: false,
                  backgroundColor: AppColors.success.withOpacity(0.1),
                  textColor: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfferButton({
    required double price,
    required String label,
    required bool isPrimary,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : () async => await onOfferSelected(price),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border:
              isPrimary
                  ? null
                  : Border.all(
                    color: backgroundColor.withOpacity(0.3),
                    width: 1,
                  ),
          boxShadow:
              isPrimary
                  ? [
                    BoxShadow(
                      color: backgroundColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Etiqueta (-0.50, Sugerido, +0.50)
            Text(
              label,
              style: AppTextStyles.interBodySmall.copyWith(
                fontSize: 10,
                color: textColor.withOpacity(0.8),
                fontWeight: isPrimary ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4),

            // Precio
            Text(
              'S/ ${price.toStringAsFixed(2)}',
              style: AppTextStyles.poppinsSubtitle.copyWith(
                fontSize: isPrimary ? 16 : 14,
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 🧮 CALCULAR PRECIO SUGERIDO: S/ 3.00 base + S/ 1.00 por km
  double _calculateSuggestedPrice(double distanceKm) {
    const double basePrice = 3.0; // S/ 3.00 base
    const double pricePerKm = 1.0; // S/ 1.00 por km

    final calculatedPrice = basePrice + (distanceKm * pricePerKm);

    // Redondear a S/ 0.50 más cercano
    return _roundToNearestHalf(calculatedPrice);
  }

  /// Redondear a S/ 0.50 más cercano
  double _roundToNearestHalf(double price) {
    return (price * 2).round() / 2;
  }
}
