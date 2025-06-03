import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../viewmodels/map_viewmodel.dart';

/// Widget del mapa principal reutilizable
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

            // Overlay de carga
            if (mapViewModel.isLoading)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ),
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
          child: _buildPickupMarker(),
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
          child: _buildDestinationMarker(),
        ),
      );
    }

    return markers;
  }

  /// Marcador de punto de recogida (pin negro con palito)
  Widget _buildPickupMarker() {
    return Column(
      children: [
        // Bola del pin
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 2),
          ),
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
        color: AppColors.info, // Azul clásico
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
  Widget _buildDestinationMarker() {
    return Column(
      children: [
        // Bola del pin
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary, // Rojo
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 2),
          ),
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
}
