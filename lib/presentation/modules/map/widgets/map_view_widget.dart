import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/route_constants.dart';
import '../viewmodels/map_viewmodel.dart';

/// Widget del mapa principal con soporte para rutas
class MapViewWidget extends StatelessWidget {
  final VoidCallback? onCurrentLocationTap;
  final bool showCurrentLocationButton;
  final bool enableTapToSelect;

  const MapViewWidget({
    super.key,
    this.onCurrentLocationTap,
    this.showCurrentLocationButton = true,
    this.enableTapToSelect = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MapViewModel>(
      builder: (context, mapViewModel, child) {
        return Stack(
          children: [
            // Mapa principal
            FlutterMap(
              mapController: mapViewModel.mapController,
              options: MapOptions(
                initialCenter: mapViewModel.currentCenter,
                initialZoom: mapViewModel.currentZoom,
                minZoom: 10.0,
                maxZoom: 18.0,
                onTap:
                    enableTapToSelect
                        ? (_, point) =>
                            mapViewModel.setPickupLocationFromTap(point)
                        : null,
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture) {
                    mapViewModel.updateMapCenter(
                      position.center!,
                      position.zoom!,
                    );
                  }
                },
              ),
              children: [
                // Capa base del mapa (OpenStreetMap)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.joyaexpress.app',
                  maxZoom: 18,
                ),

                // Capa de ruta (NUEVA)
                if (mapViewModel.hasRoute)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: mapViewModel.routePoints,
                        strokeWidth: RouteConstants.routeStrokeWidth,
                        color: AppColors.primary,
                        // SIN borderStrokeWidth ni borderColor para quitar contorno blanco
                      ),
                    ],
                  ),

                // Capa de marcadores
                MarkerLayer(markers: _buildMarkers(mapViewModel)),
              ],
            ),

            // Botón de ubicación actual
            if (showCurrentLocationButton)
              Positioned(
                bottom: 20,
                right: 20,
                child: _buildCurrentLocationButton(context, mapViewModel),
              ),

            // Overlay de carga de ruta (NUEVO)
            if (mapViewModel.isCalculatingRoute) _buildRouteLoadingOverlay(),

            // Overlay de error de ruta (NUEVO)
            if (mapViewModel.hasRouteError)
              _buildRouteErrorOverlay(context, mapViewModel),

            // Overlay de información de ruta (NUEVO)
            if (mapViewModel.hasRoute) _buildRouteInfoOverlay(mapViewModel),
          ],
        );
      },
    );
  }

  /// Construir marcadores del mapa
  List<Marker> _buildMarkers(MapViewModel mapViewModel) {
    List<Marker> markers = [];

    // SIEMPRE mostrar marcador de ubicación actual (punto azul fijo)
    if (mapViewModel.hasCurrentLocation) {
      markers.add(
        Marker(
          point: mapViewModel.currentLocation!.coordinates,
          width: 20,
          height: 20,
          child: _buildCurrentLocationMarker(),
        ),
      );
    }

    // Marcador de punto de recogida (pin negro móvil)
    if (mapViewModel.hasPickupLocation) {
      markers.add(
        Marker(
          point: mapViewModel.pickupLocation!.coordinates,
          width: 20,
          height: 35, // Más alto por el palito
          child: _buildPickupMarker(
            mapViewModel.pickupLocation!.isSnappedToRoad,
          ),
        ),
      );
    }

    // Marcador de destino
    if (mapViewModel.hasDestinationLocation) {
      markers.add(
        Marker(
          point: mapViewModel.destinationLocation!.coordinates,
          width: 20,
          height: 35,
          child: _buildDestinationMarker(
            mapViewModel.destinationLocation!.isSnappedToRoad,
          ),
        ),
      );
    }

    return markers;
  }

  /// Marcador de punto de recogida (pin negro con palito)
  Widget _buildPickupMarker(bool isSnapped) {
    return Column(
      children: [
        // Bola del pin
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSnapped ? AppColors.success : AppColors.white,
              width: 2,
            ),
          ),
          child:
              isSnapped
                  ? const Icon(Icons.check, color: AppColors.white, size: 12)
                  : null,
        ),
        // Palito del pin
        Container(width: 2, height: 15, color: AppColors.textPrimary),
      ],
    );
  }

  /// Marcador de ubicación actual (punto azul clásico)
  Widget _buildCurrentLocationMarker() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: AppColors.info,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 3,
          ),
        ],
      ),
    );
  }

  /// Marcador de destino (pin rojo)
  Widget _buildDestinationMarker(bool isSnapped) {
    return Column(
      children: [
        // Bola del pin
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSnapped ? AppColors.success : AppColors.white,
              width: 2,
            ),
          ),
          child:
              isSnapped
                  ? const Icon(Icons.check, color: AppColors.white, size: 12)
                  : null,
        ),
        // Palito del pin
        Container(width: 2, height: 15, color: AppColors.primary),
      ],
    );
  }

  /// Botón de ubicación actual
  Widget _buildCurrentLocationButton(
    BuildContext context,
    MapViewModel mapViewModel,
  ) {
    return FloatingActionButton(
      mini: true,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.primary,
      elevation: 4,
      onPressed:
          onCurrentLocationTap ??
          () {
            mapViewModel.useCurrentLocationAsPickup();
          },
      child: const Icon(Icons.my_location),
    );
  }

  /// Overlay de carga de ruta
  Widget _buildRouteLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black26,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  'Calculando ruta...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Encontrando la mejor ruta vehicular',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Overlay de error de ruta
  Widget _buildRouteErrorOverlay(
    BuildContext context,
    MapViewModel mapViewModel,
  ) {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error en la ruta',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    mapViewModel.routeErrorMessage ?? 'Error desconocido',
                    style: TextStyle(color: AppColors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.white),
              onPressed: () {
                mapViewModel.retryRouteCalculation();
              },
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.white),
              onPressed: () {
                mapViewModel.clearRoute();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Overlay de información de ruta (esquina superior)
  Widget _buildRouteInfoOverlay(MapViewModel mapViewModel) {
    return Positioned(
      top: 60,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.route, color: AppColors.primary, size: 16),
            const SizedBox(width: 6),
            Text(
              '${mapViewModel.routeDistance.toStringAsFixed(1)} km',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.access_time, color: AppColors.textSecondary, size: 14),
            const SizedBox(width: 4),
            Text(
              '${mapViewModel.routeDuration} min',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
