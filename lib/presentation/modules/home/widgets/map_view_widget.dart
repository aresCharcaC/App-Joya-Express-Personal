import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/route_constants.dart';
import '../viewmodels/map_viewmodel.dart';
import 'route_error_overlay.dart';

/// Widget del mapa principal con PINS CORREGIDOS (punta del palito marca posición)
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
                      position.center,
                      position.zoom,
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

                // Capa de ruta
                if (mapViewModel.hasRoute)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: mapViewModel.routePoints,
                        strokeWidth: RouteConstants.routeStrokeWidth,
                        color: AppColors.primary,
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

            // Overlay de carga de ruta
            if (mapViewModel.isCalculatingRoute) _buildRouteLoadingOverlay(),

            // NUEVO: Overlay de error mejorado
            if (mapViewModel.hasRouteError)
              RouteErrorOverlay(
                errorMessage:
                    mapViewModel.routeErrorMessage ?? 'Error desconocido',
                onRetry: () => mapViewModel.retryRouteCalculation(),
                onClearLocations: () => mapViewModel.clearAllLocations(),
                onDismiss: () => mapViewModel.dismissRouteError(),
              ),

            // Overlay de información de ruta (MOVIDO MÁS ABAJO)
            if (mapViewModel.hasRoute) _buildRouteInfoOverlay(mapViewModel),
          ],
        );
      },
    );
  }

  /// Construir marcadores del mapa CON PINS CORREGIDOS
  List<Marker> _buildMarkers(MapViewModel mapViewModel) {
    List<Marker> markers = [];

    // Marcador de ubicación actual (punto azul fijo)
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

    // Marcador de punto de recogida (pin negro móvil) con indicador
    if (mapViewModel.hasPickupLocation) {
      // Marcador principal (pin negro)
      markers.add(
        Marker(
          point: mapViewModel.pickupLocation!.coordinates,
          width: 20,
          height: 35,
          child: _buildPickupMarker(
            mapViewModel.pickupLocation!.isSnappedToRoad,
          ),
        ),
      );

      // Marcador del indicador de texto
      markers.add(
        Marker(
          point: mapViewModel.pickupLocation!.coordinates,
          width: 120,
          height: 35,
          alignment: Alignment.topCenter,
          child: Transform.translate(
            offset: const Offset(0, -50),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Punto de recogida',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  letterSpacing: 0.2,
                ),
              ),
            ),
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

  /// Marcador de punto de recogida (pin negro con palito) - AJUSTADO CORRECTAMENTE
  Widget _buildPickupMarker(bool isSnapped) {
    return Transform.translate(
      // ✅ MOVER EL PIN HACIA ARRIBA para que la punta toque la coordenada
      offset: const Offset(0, -17.5), // La mitad de la altura (35/2)
      child: Column(
        children: [
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
          Container(width: 2, height: 15, color: AppColors.textPrimary),
        ],
      ),
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

  /// Marcador de destino (pin rojo) - AJUSTADO CORRECTAMENTE
  Widget _buildDestinationMarker(bool isSnapped) {
    return Transform.translate(
      // ✅ MOVER EL PIN HACIA ARRIBA para que la punta toque la coordenada
      offset: const Offset(0, -17.5), // La mitad de la altura (35/2)
      child: Column(
        children: [
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
          Container(width: 2, height: 15, color: AppColors.primary),
        ],
      ),
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
                  'Calculando ruta vehicular...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Encontrando la mejor ruta para mototaxis',
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

  /// Overlay de información de ruta (MOVIDO MÁS ABAJO)
  Widget _buildRouteInfoOverlay(MapViewModel mapViewModel) {
    return Positioned(
      top: 120, // CAMBIADO: Más abajo para no chocar con el menú
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
