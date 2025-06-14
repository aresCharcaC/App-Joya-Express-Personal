// lib/presentation/modules/auth/Driver/screens/request_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:joya_express/data/models/user/ride_request_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';
import '../viewmodels/driver_home_viewmodel.dart';

class RequestDetailScreen extends StatelessWidget {
  final MockSolicitud solicitud;

  const RequestDetailScreen({super.key, required this.solicitud});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Detalle de Solicitud',
          style: AppTextStyles.poppinsHeading2,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Mapa con los 3 puntos
          Expanded(flex: 3, child: _buildMap(context)),

          // Información del pasajero y botones
          Expanded(flex: 2, child: _buildInfoSection(context)),
        ],
      ),
    );
  }

  Widget _buildMap(BuildContext context) {
    final conductorPosition =
        context.read<DriverHomeViewModel>().currentPosition;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(solicitud.origenLat, solicitud.origenLng),
            initialZoom: 14.0,
            minZoom: 10.0,
            maxZoom: 18.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.joyaexpress.app',
              maxZoom: 18,
            ),
            MarkerLayer(markers: _buildMarkers(conductorPosition)),
          ],
        ),
      ),
    );
  }

  List<Marker> _buildMarkers(dynamic conductorPosition) {
    final List<Marker> markers = [];

    // 📍 Marcador del conductor (azul)
    if (conductorPosition != null) {
      markers.add(
        Marker(
          point: LatLng(
            conductorPosition.latitude,
            conductorPosition.longitude,
          ),
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue[600],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.directions_car,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }

    // 🟢 Marcador del punto de recogida (verde)
    markers.add(
      Marker(
        point: LatLng(solicitud.origenLat, solicitud.origenLng),
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green[600],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 20),
        ),
      ),
    );

    // 🔴 Marcador del punto de destino (rojo)
    markers.add(
      Marker(
        point: LatLng(solicitud.destinoLat, solicitud.destinoLng),
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.red[600],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.location_on, color: Colors.white, size: 20),
        ),
      ),
    );

    return markers;
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información del pasajero
          _buildPassengerInfo(),

          const SizedBox(height: 16),

          // Direcciones
          _buildAddressInfo(),

          const SizedBox(height: 16),

          // Precio y métodos de pago
          _buildPriceInfo(),

          const Spacer(),

          // Botón de aceptar
          _buildAcceptButton(context),
        ],
      ),
    );
  }

  Widget _buildPassengerInfo() {
    return Row(
      children: [
        // Foto del pasajero
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: ClipOval(
            child:
                solicitud.foto.isNotEmpty
                    ? Image.network(
                      solicitud.foto,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildAvatarFallback(),
                    )
                    : _buildAvatarFallback(),
          ),
        ),

        const SizedBox(width: 16),

        // Nombre y rating
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                solicitud.nombre,
                style: AppTextStyles.poppinsHeading3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${solicitud.rating.toStringAsFixed(1)} (${solicitud.votos} votos)',
                    style: AppTextStyles.poppinsHeading2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      color: AppColors.primaryLight,
      child: Center(
        child: Text(
          solicitud.nombre.isNotEmpty ? solicitud.nombre[0].toUpperCase() : '?',
          style: AppTextStyles.poppinsHeading2.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAddressInfo() {
    return Column(
      children: [
        // Origen
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.green[600],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recogida',
                    style: AppTextStyles.poppinsHeading2.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    solicitud.direccion,
                    style: AppTextStyles.poppinsHeading1.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Línea conectora
        Container(
          margin: const EdgeInsets.only(left: 6),
          width: 1,
          height: 20,
          color: AppColors.greyLight,
        ),

        const SizedBox(height: 12),

        // Destino
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.red[600],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Destino',
                    style: AppTextStyles.poppinsHeading2.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    solicitud.destinoDireccion,
                    style: AppTextStyles.poppinsHeading1.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Row(
        children: [
          // Precio
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Precio Ofrecido',
                  style: AppTextStyles.poppinsHeading2.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'S/ ${solicitud.precio.toStringAsFixed(2)}',
                  style: AppTextStyles.poppinsHeading2.copyWith(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Métodos de pago
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Métodos de Pago',
                  style: AppTextStyles.poppinsHeading2.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children:
                      solicitud.metodos.map((metodo) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getPaymentMethodColor(metodo),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            metodo,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => _handleAccept(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          'Aceptar por S/ ${solicitud.precio.toStringAsFixed(2)}',
          style: AppTextStyles.poppinsHeading1.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Color _getPaymentMethodColor(String metodo) {
    switch (metodo.toLowerCase()) {
      case 'yape':
        return const Color(0xFF722F87); // Morado Yape
      case 'plin':
        return const Color(0xFF00BCD4); // Celeste Plin
      case 'efectivo':
        return const Color(0xFF4CAF50); // Verde Efectivo
      default:
        return AppColors.greyLight;
    }
  }

  void _handleAccept(BuildContext context) {
    // Mostrar confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Solicitud de ${solicitud.nombre} aceptada'),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    // Eliminar solicitud de la lista
    context.read<DriverHomeViewModel>().rejectRequest(solicitud.rideId);

    // Regresar a la pantalla principal
    Navigator.pop(context);
  }
}
