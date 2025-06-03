import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../domain/entities/location_entity.dart';
import '../../../../data/services/location_service.dart';
import '../widgets/map_view_widget.dart';
import '../viewmodels/map_viewmodel.dart';

/// Pantalla para seleccionar destino tocando en el mapa (MENOS SENSIBLE)
class MapSelectionScreen extends StatefulWidget {
  const MapSelectionScreen({super.key});

  @override
  State<MapSelectionScreen> createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();
  LocationEntity? _selectedLocation;
  bool _isProcessingLocation = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2D2D), // Color oscuro
      body: Consumer<MapViewModel>(
        builder: (context, mapViewModel, child) {
          return Stack(
            children: [
              // Mapa principal (SIN overlay de gestures conflictivos)
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: mapViewModel.currentCenter,
                  initialZoom: mapViewModel.currentZoom,
                  minZoom: 10.0,
                  maxZoom: 18.0,
                  // SOLO onTap para seleccionar, SIN onPanUpdate ni onScaleUpdate
                  onTap: (tapPosition, point) => _handleMapTap(point),
                  // Permitir interacciones normales del mapa
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all, // Zoom, pan, etc.
                  ),
                ),
                children: [
                  // Capa base del mapa
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.joyaexpress.app',
                    maxZoom: 18,
                  ),

                  // Marcadores
                  MarkerLayer(markers: _buildMarkers(mapViewModel)),
                ],
              ),

              // Header con botones
              _buildHeader(context),

              // Indicador de ubicación seleccionada
              if (_selectedLocation != null) _buildLocationIndicator(),

              // Overlay de procesamiento
              if (_isProcessingLocation) _buildProcessingOverlay(),
            ],
          );
        },
      ),
    );
  }

  /// Construir marcadores del mapa
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

    // Marcador de punto de recogida (pin negro)
    if (mapViewModel.hasPickupLocation) {
      markers.add(
        Marker(
          point: mapViewModel.pickupLocation!.coordinates,
          width: 20,
          height: 35,
          child: _buildPickupMarker(),
        ),
      );
    }

    // Marcador de destino seleccionado temporalmente
    if (_selectedLocation != null) {
      markers.add(
        Marker(
          point: _selectedLocation!.coordinates,
          width: 20,
          height: 35,
          child: _buildDestinationMarker(),
        ),
      );
    }

    return markers;
  }

  /// Marcador de ubicación actual (punto azul)
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

  /// Marcador de punto de recogida (pin negro)
  Widget _buildPickupMarker() {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 2),
          ),
        ),
        Container(width: 2, height: 15, color: AppColors.textPrimary),
      ],
    );
  }

  /// Marcador de destino (pin rojo)
  Widget _buildDestinationMarker() {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 2),
          ),
        ),
        Container(width: 2, height: 15, color: AppColors.primary),
      ],
    );
  }

  /// Header con botones
  Widget _buildHeader(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botón atrás
              Container(
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF2D2D2D,
                  ).withOpacity(0.9), // Color oscuro
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Título
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF2D2D2D,
                  ).withOpacity(0.9), // Color oscuro
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Seleccionar destino',
                  style: AppTextStyles.interBody.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                  ),
                ),
              ),

              // Botón confirmar
              Container(
                decoration: BoxDecoration(
                  color:
                      _selectedLocation != null
                          ? AppColors.primary
                          : AppColors.buttonDisabled,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.check, color: AppColors.white),
                  onPressed:
                      _selectedLocation != null ? _confirmSelection : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Indicador de ubicación seleccionada
  Widget _buildLocationIndicator() {
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D), // Color oscuro
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Destino seleccionado',
                  style: AppTextStyles.interCaption.copyWith(
                    color: AppColors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _selectedLocation!.address ?? 'Ubicación personalizada',
              style: AppTextStyles.interBody.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: AppColors.info),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Toca ✓ para confirmar o selecciona otro punto',
                    style: AppTextStyles.interCaption.copyWith(
                      color: AppColors.white.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Overlay de procesamiento
  Widget _buildProcessingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  'Procesando ubicación...',
                  style: AppTextStyles.interBody.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Manejar toque en el mapa (MENOS SENSIBLE)
  void _handleMapTap(LatLng coordinates) async {
    setState(() {
      _isProcessingLocation = true;
    });

    try {
      // Convertir coordenadas a LocationEntity
      final location = await _locationService.coordinatesToLocation(
        coordinates,
      );

      setState(() {
        _selectedLocation = location;
        _isProcessingLocation = false;
      });

      print(
        'Destino seleccionado: ${coordinates.latitude}, ${coordinates.longitude}',
      );
    } catch (e) {
      setState(() {
        _isProcessingLocation = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar ubicación: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Confirmar selección
  void _confirmSelection() {
    if (_selectedLocation != null) {
      Navigator.pop(context, _selectedLocation);
    }
  }
}
