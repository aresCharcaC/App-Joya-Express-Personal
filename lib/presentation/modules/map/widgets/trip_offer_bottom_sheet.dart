// lib/presentation/modules/map/widgets/trip_offer_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_strings.dart';
import '../viewmodels/map_viewmodel.dart';

/// Bottom sheet para configurar tarifa del viaje (90% de pantalla)
class TripOfferBottomSheet extends StatefulWidget {
  const TripOfferBottomSheet({super.key});

  @override
  State<TripOfferBottomSheet> createState() => _TripOfferBottomSheetState();
}

class _TripOfferBottomSheetState extends State<TripOfferBottomSheet> {
  final TextEditingController _priceController = TextEditingController();
  final FocusNode _priceFocusNode = FocusNode();

  double _recommendedPrice = 0.0;
  double _userPrice = 0.0;
  bool _isUsingRecommendedPrice = true;

  @override
  void initState() {
    super.initState();
    _initializePrices();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _priceFocusNode.dispose();
    super.dispose();
  }

  void _initializePrices() {
    final mapViewModel = Provider.of<MapViewModel>(context, listen: false);

    if (mapViewModel.hasRoute) {
      // Calcular precio recomendado: 3 soles base + 1 sol por km
      final distanceKm = mapViewModel.routeDistance;
      _recommendedPrice = 3.0 + (distanceKm * 1.0);

      // Redondear a .5 más cercano para precios más amigables
      _recommendedPrice = ((_recommendedPrice * 2).round()) / 2;

      _userPrice = _recommendedPrice;
      _priceController.text = _userPrice.toStringAsFixed(0);
    }
  }

  void _onPriceChanged(String value) {
    final price = double.tryParse(value);
    if (price != null && price >= 0) {
      setState(() {
        _userPrice = price;
        _isUsingRecommendedPrice = (price == _recommendedPrice);
      });
    }
  }

  void _useRecommendedPrice() {
    setState(() {
      _userPrice = _recommendedPrice;
      _isUsingRecommendedPrice = true;
      _priceController.text = _userPrice.toStringAsFixed(0);
    });
  }

  void _confirmOffer() {
    // TODO: Implementar lógica de búsqueda de mototaxi
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Buscando mototaxi por S/${_userPrice.toStringAsFixed(0)}',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapViewModel>(
      builder: (context, mapViewModel, child) {
        if (!mapViewModel.hasRoute) {
          return const SizedBox.shrink();
        }

        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle del bottom sheet
                  _buildHandle(),

                  // Contenido scrolleable
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sección de precio
                          _buildPriceSection(),

                          const SizedBox(height: 32),

                          // Métodos de pago
                          _buildPaymentMethodsSection(),

                          const SizedBox(height: 32),

                          // Información de la ruta
                          _buildRouteInfoSection(mapViewModel),

                          const SizedBox(height: 40),

                          // Botón confirmar
                          _buildConfirmButton(),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de precio editable grande
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.greyLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  _priceFocusNode.hasFocus
                      ? AppColors.primary
                      : AppColors.border,
              width: _priceFocusNode.hasFocus ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'S/',
                    style: AppTextStyles.poppinsHeading1.copyWith(
                      fontSize: 48,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Flexible(
                    child: IntrinsicWidth(
                      child: TextField(
                        controller: _priceController,
                        focusNode: _priceFocusNode,
                        style: AppTextStyles.poppinsHeading1.copyWith(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d{1,3}$'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: _onPriceChanged,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Precio recomendado
        GestureDetector(
          onTap: _useRecommendedPrice,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  _isUsingRecommendedPrice
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    _isUsingRecommendedPrice
                        ? AppColors.primary
                        : AppColors.border,
                width: _isUsingRecommendedPrice ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Precio Recomendado:',
                      style: AppTextStyles.interBodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'S/${_recommendedPrice.toStringAsFixed(0)}',
                      style: AppTextStyles.poppinsHeading3.copyWith(
                        color:
                            _isUsingRecommendedPrice
                                ? AppColors.primary
                                : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (_isUsingRecommendedPrice)
                  Icon(Icons.check_circle, color: AppColors.primary, size: 24)
                else
                  Text('Usar', style: AppTextStyles.interLink),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.payment, color: AppColors.textPrimary, size: 20),
            const SizedBox(width: 8),
            Text('Métodos de Pago', style: AppTextStyles.poppinsHeading3),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.greyLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.payments_outlined,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Efectivo',
                      style: AppTextStyles.interBody.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Pago al conductor',
                      style: AppTextStyles.interCaption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.check_circle, color: AppColors.success, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRouteInfoSection(MapViewModel mapViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Detalles del Viaje', style: AppTextStyles.poppinsHeading3),
        const SizedBox(height: 16),

        // Origen
        _buildRoutePoint(
          icon: Icons.trip_origin,
          iconColor: AppColors.textPrimary,
          title: 'Desde',
          address:
              mapViewModel.pickupLocation?.address ?? 'Ubicación de origen',
        ),

        const SizedBox(height: 12),

        // Destino
        _buildRoutePoint(
          icon: Icons.place,
          iconColor: AppColors.primary,
          title: 'Hasta',
          address:
              mapViewModel.destinationLocation?.address ??
              'Ubicación de destino',
        ),

        const SizedBox(height: 16),

        // Información adicional
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.info.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cerca de ${mapViewModel.routeDistance.toStringAsFixed(1)}km • ${mapViewModel.routeDuration} min aprox.',
                  style: AppTextStyles.interBody.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoutePoint({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String address,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.interCaption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                address,
                style: AppTextStyles.interBody.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    final isValidPrice = _userPrice >= 1.0 && _userPrice <= 999.0;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isValidPrice ? _confirmOffer : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isValidPrice ? AppColors.primary : AppColors.buttonDisabled,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Buscar Mototaxi',
          style: AppTextStyles.poppinsButton.copyWith(
            color:
                isValidPrice ? AppColors.white : AppColors.buttonTextDisabled,
          ),
        ),
      ),
    );
  }
}
