// lib/presentation/modules/auth/Driver/widgets/trip_map_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:joya_express/core/constants/app_colors.dart';

class TripMapWidget extends StatelessWidget {
  final double conductorLat;
  final double conductorLng;
  final double origenLat;
  final double origenLng;
  final double destinoLat;
  final double destinoLng;

  const TripMapWidget({
    super.key,
    required this.conductorLat,
    required this.conductorLng,
    required this.origenLat,
    required this.origenLng,
    required this.destinoLat,
    required this.destinoLng,
  });

  @override
  Widget build(BuildContext context) {
    // Coordenadas de los 3 puntos
    final conductorPoint = LatLng(conductorLat, conductorLng);
    final origenPoint = LatLng(origenLat, origenLng);
    final destinoPoint = LatLng(destinoLat, destinoLng);

    // Calcular bounds para mostrar todos los puntos
    final bounds = _calculateBounds([
      conductorPoint,
      origenPoint,
      destinoPoint,
    ]);

    return FlutterMap(
      options: MapOptions(
        initialCameraFit: CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(
            50,
          ), // Padding para que no queden en el borde
        ),
        interactionOptions: const InteractionOptions(
          flags:
              InteractiveFlag.all &
              ~InteractiveFlag.rotate, // Deshabilitar rotación
        ),
      ),
      children: [
        // 🗺️ TILES DEL MAPA
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.joyaexpress.app',
        ),

        // 🛣️ RUTAS
        PolylineLayer(
          polylines: [
            // Ruta: Conductor → Origen (Azul)
            Polyline(
              points: [conductorPoint, origenPoint],
              strokeWidth: 4.0,
              color: Colors.blue,
            ),
            // Ruta: Origen → Destino (Verde)
            Polyline(
              points: [origenPoint, destinoPoint],
              strokeWidth: 5.0,
              color: AppColors.success,
            ),
          ],
        ),

        // 📍 MARCADORES
        MarkerLayer(
          markers: [
            // 🔵 CONDUCTOR (Azul)
            Marker(
              point: conductorPoint,
              width: 40,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ),

            // ⚫ ORIGEN (Negro)
            Marker(
              point: origenPoint,
              width: 35,
              height: 35,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black87,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // 🔴 DESTINO (Rojo)
            Marker(
              point: destinoPoint,
              width: 35,
              height: 35,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'B',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Calcular bounds para mostrar todos los puntos
  LatLngBounds _calculateBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    return LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));
  }
}
