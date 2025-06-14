// lib/presentation/modules/map/widgets/trip_offer_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../viewmodels/map_viewmodel.dart';
import '../../../../presentation/providers/ride_provider.dart';
import '../../../../domain/entities/ride_request_entity.dart';

/// Bottom sheet para configurar tarifa del viaje (DISEÑO ACTUALIZADO)
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
  bool _isLoading = false;

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
      _recommendedPrice = ((_recommendedPrice * 2).round()) / 2;

      _userPrice = _recommendedPrice;
      _priceController.text = '';
    }
  }

  void _onPriceChanged(String value) {
    final price = double.tryParse(value);
    if (price != null && price >= 0) {
      setState(() {
        _userPrice = price;
      });
    }
  }

  Future<void> _confirmOffer() async {
    final mapViewModel = Provider.of<MapViewModel>(context, listen: false);
    final rideProvider = Provider.of<RideProvider>(context, listen: false);

    if (!mapViewModel.hasRoute || !mapViewModel.hasPickupLocation || !mapViewModel.hasDestinationLocation) {
      Navigator.pop(context); // Cerrar el BottomSheet primero
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se puede crear la solicitud de viaje'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Crear la solicitud de viaje
      final request = RideRequest(
        origenLat: mapViewModel.pickupLocation!.coordinates.latitude,
        origenLng: mapViewModel.pickupLocation!.coordinates.longitude,
        destinoLat: mapViewModel.destinationLocation!.coordinates.latitude,
        destinoLng: mapViewModel.destinationLocation!.coordinates.longitude,
        origenDireccion: mapViewModel.pickupLocation!.address,
        destinoDireccion: mapViewModel.destinationLocation!.address,
        precioSugerido: _userPrice,
        metodoPagoPreferido: 'efectivo', // Por defecto efectivo
        estado: 'pendiente',
        fechaCreacion: DateTime.now(),
      );

      // Crear la solicitud usando el provider
      final success = await rideProvider.createRideRequest(request);

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Buscando mototaxi por S/${_userPrice.toStringAsFixed(0)}',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          // Cerrar el BottomSheet antes de mostrar el error
          Navigator.pop(context);
          
          // Si no fue exitoso, mostrar el error del provider
          String errorMessage = 'Error al crear la solicitud';
          
          if (rideProvider.error != null) {
            if (rideProvider.error!.contains('NO hay conductores cercanos disponibles')) {
              errorMessage = 'No hay conductores disponibles en tu zona. Por favor, intenta más tarde.';
            } else if (rideProvider.error!.contains('Error de validación')) {
              errorMessage = 'Error en los datos de la solicitud. Por favor, verifica la información.';
            } else if (rideProvider.error!.contains('Error de autenticación')) {
              errorMessage = 'Error de sesión. Por favor, vuelve a iniciar sesión.';
            } else if (rideProvider.error!.contains('Error de conexión')) {
              errorMessage = 'Error de conexión. Por favor, verifica tu conexión a internet.';
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: AppColors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Entendido',
                textColor: AppColors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Cerrar el BottomSheet antes de mostrar el error
        Navigator.pop(context);
        
        String errorMessage = 'Error al crear la solicitud';
        
        if (e.toString().contains('NO hay conductores cercanos disponibles')) {
          errorMessage = 'No hay conductores disponibles en tu zona. Por favor, intenta más tarde.';
        } else if (e.toString().contains('Error de validación')) {
          errorMessage = 'Error en los datos de la solicitud. Por favor, verifica la información.';
        } else if (e.toString().contains('Error de autenticación')) {
          errorMessage = 'Error de sesión. Por favor, vuelve a iniciar sesión.';
        } else if (e.toString().contains('Error de conexión')) {
          errorMessage = 'Error de conexión. Por favor, verifica tu conexión a internet.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: AppColors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Entendido',
              textColor: AppColors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapViewModel>(
      builder: (context, mapViewModel, child) {
        if (!mapViewModel.hasRoute) {
          return const SizedBox.shrink();
        }

        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Color(0xFF2D2D2D), // Fondo oscuro como en la imagen
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle del bottom sheet
              _buildHandle(),

              // Contenido principal
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Campo de precio grande (IGUAL AL DISEÑO)
                      _buildPriceInputSection(),

                      const SizedBox(height: 32),

                      // Métodos de pago (IGUAL AL DISEÑO)
                      _buildPaymentMethodsSection(),

                      const SizedBox(height: 32),

                      // Información de ruta (IGUAL AL DISEÑO)
                      _buildRouteInfoSection(mapViewModel),

                      const Spacer(),

                      // Botón buscar mototaxi (IGUAL AL DISEÑO)
                      _buildSearchButton(),

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
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// Campo de precio grande EXACTAMENTE como en la imagen
  Widget _buildPriceInputSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF505050), // Gris más claro
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Campo de entrada de precio grande
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'S/',
                style: AppTextStyles.poppinsHeading1.copyWith(
                  fontSize: 48,
                  color: AppColors.white,
                  fontWeight: FontWeight.w300,
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
                      color: AppColors.white,
                    ),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d{1,3}$')),
                    ],
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: _recommendedPrice.toStringAsFixed(0),
                      hintStyle: AppTextStyles.poppinsHeading1.copyWith(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white.withOpacity(0.3),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: _onPriceChanged,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Precio recomendado IGUAL AL DISEÑO
          Text(
            'Precio Recomendado: S/${_recommendedPrice.toStringAsFixed(0)}',
            style: AppTextStyles.interBody.copyWith(
              color: AppColors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Métodos de pago como botón centrado (SIN funcionalidad por ahora)
  Widget _buildPaymentMethodsSection() {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF505050),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.credit_card, color: AppColors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              'Métodos de Pago',
              style: AppTextStyles.poppinsHeading3.copyWith(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.white.withOpacity(0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// Información de ruta EXACTAMENTE como en la imagen
  Widget _buildRouteInfoSection(MapViewModel mapViewModel) {
    return Column(
      children: [
        // Punto de origen con ícono rojo
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF505050),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Ícono rojo de ubicación
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  mapViewModel.pickupLocation?.address ?? 'Av. Arequipa 112',
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
        ),

        const SizedBox(height: 12),

        // Punto de destino con ícono rojo
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF505050),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Ícono rojo de ubicación (destino)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mapViewModel.destinationLocation?.address ??
                          mapViewModel.destinationLocation?.name ??
                          'Vivero Tecnoplants',
                      style: AppTextStyles.interBody.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Cerca de ${mapViewModel.routeDistance.toStringAsFixed(1)}km',
                      style: AppTextStyles.interCaption.copyWith(
                        color: AppColors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Botón de búsqueda IGUAL AL DISEÑO
  Widget _buildSearchButton() {
    final isValidPrice =
        (_userPrice >= 1.0 && _userPrice <= 999.0) ||
        _priceController.text.isEmpty;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isValidPrice && !_isLoading ? _confirmOffer : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Buscar Mototaxi',
                style: AppTextStyles.poppinsButton.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
