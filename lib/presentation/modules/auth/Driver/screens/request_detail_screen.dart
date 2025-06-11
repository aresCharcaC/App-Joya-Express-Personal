// lib/presentation/modules/auth/Driver/screens/request_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';
import '../widgets/trip_map_widget.dart';
import '../widgets/compact_passenger_info.dart';
import '../widgets/price_offer_buttons.dart';

class RequestDetailScreen extends StatefulWidget {
  final dynamic request;
  final Function(String rideId, double tarifa, int tiempo, String? mensaje)?
  onMakeOffer;
  final Function(String rideId)? onReject;

  const RequestDetailScreen({
    super.key,
    required this.request,
    this.onMakeOffer,
    this.onReject,
  });

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 🗺️ MAPA 60% - Ocupa toda la parte superior
          Expanded(
            flex: 6, // 60% de la pantalla
            child: TripMapWidget(
              conductorLat: -16.4079, // Posición actual del conductor
              conductorLng: -71.4821,
              origenLat: widget.request.origenLat ?? -16.4085,
              origenLng: widget.request.origenLng ?? -71.5375,
              destinoLat: widget.request.destinoLat ?? -16.4095,
              destinoLng: widget.request.destinoLng ?? -71.5380,
            ),
          ),

          // 📱 INFO + BOTONES 40% - Parte inferior
          Expanded(
            flex: 4, // 40% de la pantalla
            child: Container(
              color: AppColors.white,
              child: Column(
                children: [
                  // 👤 INFO PASAJERO COMPACTA
                  CompactPassengerInfo(request: widget.request),

                  // Línea divisoria
                  Divider(color: AppColors.greyLight, height: 1),

                  // 💰 BOTÓN ACEPTAR PRECIO USUARIO
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            _isLoading ? null : () => _handleAcceptUserPrice(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: AppColors.white,
                                )
                                : Text(
                                  'Aceptar por S/ ${widget.request.precio?.toStringAsFixed(2) ?? "0.00"}',
                                  style: AppTextStyles.poppinsButton.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                      ),
                    ),
                  ),

                  // 🔄 CONTRA-OFERTAS
                  PriceOfferButtons(
                    userRequestedPrice:
                        widget.request.precio?.toDouble() ?? 8.0,
                    distanceKm: widget.request.distanciaKm?.toDouble() ?? 2.5,
                    onOfferSelected:
                        (double selectedPrice) =>
                            _handleMakeOffer(selectedPrice),
                    isLoading: _isLoading,
                  ),

                  // ❌ BOTÓN CERRAR
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cerrar',
                        style: AppTextStyles.poppinsSubtitle.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  // Padding bottom para SafeArea
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Aceptar el precio que pidió el usuario
  Future<void> _handleAcceptUserPrice() async {
    final userPrice = widget.request.precio?.toDouble() ?? 0.0;
    await _handleMakeOffer(userPrice);
  }

  /// Hacer oferta con precio específico
  Future<void> _handleMakeOffer(double selectedPrice) async {
    setState(() => _isLoading = true);

    try {
      final rideId = widget.request.rideId ?? '';
      final tiempoEstimado = widget.request.tiempoEstimadoMinutos ?? 10;

      final success =
          await widget.onMakeOffer?.call(
            rideId,
            selectedPrice,
            tiempoEstimado,
            'Oferta desde la app', // Mensaje por defecto
          ) ??
          true;

      if (success) {
        Navigator.pop(context);
        _showSnackBar('Oferta enviada exitosamente', isError: false);
      } else {
        _showSnackBar('Error al enviar oferta', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
