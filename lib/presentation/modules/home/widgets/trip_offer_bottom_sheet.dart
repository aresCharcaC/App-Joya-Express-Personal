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
  String _selectedPaymentMethod =
      'efectivo'; // Método de pago seleccionado por defecto

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
      // Redondear a 0.50 más cercano para permitir decimales
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

    if (!mapViewModel.hasRoute ||
        !mapViewModel.hasPickupLocation ||
        !mapViewModel.hasDestinationLocation) {
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
        metodoPagoPreferido:
            _selectedPaymentMethod, // Usar el método seleccionado
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
                'Buscando mototaxi por S/${_userPrice.toStringAsFixed(2)}',
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
            if (rideProvider.error!.contains(
              'NO hay conductores cercanos disponibles',
            )) {
              errorMessage =
                  'No hay conductores disponibles en tu zona. Por favor, intenta más tarde.';
            } else if (rideProvider.error!.contains('Error de validación')) {
              errorMessage =
                  'Error en los datos de la solicitud. Por favor, verifica la información.';
            } else if (rideProvider.error!.contains('Error de autenticación')) {
              errorMessage =
                  'Error de sesión. Por favor, vuelve a iniciar sesión.';
            } else if (rideProvider.error!.contains('Error de conexión')) {
              errorMessage =
                  'Error de conexión. Por favor, verifica tu conexión a internet.';
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
          errorMessage =
              'No hay conductores disponibles en tu zona. Por favor, intenta más tarde.';
        } else if (e.toString().contains('Error de validación')) {
          errorMessage =
              'Error en los datos de la solicitud. Por favor, verifica la información.';
        } else if (e.toString().contains('Error de autenticación')) {
          errorMessage = 'Error de sesión. Por favor, vuelve a iniciar sesión.';
        } else if (e.toString().contains('Error de conexión')) {
          errorMessage =
              'Error de conexión. Por favor, verifica tu conexión a internet.';
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
          height:
              MediaQuery.of(context).size.height *
              0.85, // Reducido para evitar overflow
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

              // Contenido principal con scroll
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 10), // Reducido
                      // Campo de precio grande (OPTIMIZADO)
                      _buildPriceInputSection(),

                      const SizedBox(height: 20), // Reducido
                      // Métodos de pago (FUNCIONAL)
                      _buildPaymentMethodsSection(),

                      const SizedBox(height: 20), // Reducido
                      // Información de ruta (OPTIMIZADO)
                      _buildRouteInfoSection(mapViewModel),

                      const SizedBox(height: 24), // Espacio antes del botón
                      // Botón buscar mototaxi
                      _buildSearchButton(),

                      const SizedBox(height: 20), // Espacio final
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

  /// Campo de precio grande OPTIMIZADO para menos espacio
  Widget _buildPriceInputSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20), // Reducido de 24 a 20
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
                  fontSize: 40, // Reducido de 48 a 40
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
                      fontSize: 56, // Reducido de 64 a 56
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d{1,3}(\.\d{0,2})?$'),
                      ),
                    ],
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: _recommendedPrice.toStringAsFixed(2),
                      hintStyle: AppTextStyles.poppinsHeading1.copyWith(
                        fontSize: 56, // Reducido de 64 a 56
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

          const SizedBox(height: 12), // Reducido de 16 a 12
          // Precio recomendado
          Text(
            'Precio Recomendado: S/${_recommendedPrice.toStringAsFixed(0)}',
            style: AppTextStyles.interBody.copyWith(
              color: AppColors.white.withOpacity(0.7),
              fontSize: 14, // Reducido de 16 a 14
            ),
          ),
        ],
      ),
    );
  }

  /// Selector de métodos de pago funcional
  Widget _buildPaymentMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Método de Pago',
            style: AppTextStyles.interBody.copyWith(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Opciones de pago
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF505050),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Efectivo
              _buildPaymentOption(
                'efectivo',
                'Efectivo',
                Icons.money,
                'Paga directamente al conductor',
              ),

              // Divisor
              Container(
                height: 1,
                color: AppColors.white.withOpacity(0.1),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),

              // Yape
              _buildPaymentOption(
                'yape',
                'Yape',
                Icons.phone_android,
                'Pago digital con Yape',
              ),

              // Divisor
              Container(
                height: 1,
                color: AppColors.white.withOpacity(0.1),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),

              // Transferencia (Plin)
              _buildPaymentOption(
                'transferencia',
                'Plin',
                Icons.account_balance_wallet,
                'Pago digital con Plin',
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Widget para cada opción de pago (COMPACTO)
  Widget _buildPaymentOption(
    String value,
    String title,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = _selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ), // Reducido padding vertical
        child: Row(
          children: [
            // Icono del método de pago (más pequeño)
            Container(
              width: 32, // Reducido de 40 a 32
              height: 32, // Reducido de 40 a 32
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? AppColors.primary.withOpacity(0.2)
                        : AppColors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6), // Reducido de 8 a 6
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.white,
                size: 18, // Reducido de 20 a 18
              ),
            ),

            const SizedBox(width: 10), // Reducido de 12 a 10
            // Información del método (más compacta)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.interBody.copyWith(
                      color: AppColors.white,
                      fontSize: 15, // Reducido de 16 a 15
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.interCaption.copyWith(
                      color: AppColors.white.withOpacity(0.7),
                      fontSize: 11, // Reducido de 12 a 11
                    ),
                  ),
                ],
              ),
            ),

            // Radio button (más pequeño)
            Container(
              width: 18, // Reducido de 20 a 18
              height: 18, // Reducido de 20 a 18
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected
                          ? AppColors.primary
                          : AppColors.white.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child:
                  isSelected
                      ? Center(
                        child: Container(
                          width: 8, // Reducido de 10 a 8
                          height: 8, // Reducido de 10 a 8
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                      : null,
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
        child:
            _isLoading
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
