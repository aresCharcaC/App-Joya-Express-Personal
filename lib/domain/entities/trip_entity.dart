import 'package:latlong2/latlong.dart';
import './location_entity.dart';

/// Entidad que representa un viaje completo calculado
class TripEntity {
  final List<LatLng> routePoints;
  final double distanceKm;
  final int durationMinutes;
  final LocationEntity pickup;
  final LocationEntity destination;
  final DateTime calculatedAt;
  final String?
  routingEngine; // Indica qué motor de routing se usó (OSRM, etc.)
  final Map<String, dynamic>? metadata; // Metadatos adicionales del routing

  const TripEntity({
    required this.routePoints,
    required this.distanceKm,
    required this.durationMinutes,
    required this.pickup,
    required this.destination,
    required this.calculatedAt,
    this.routingEngine,
    this.metadata,
  });

  TripEntity copyWith({
    List<LatLng>? routePoints,
    double? distanceKm,
    int? durationMinutes,
    LocationEntity? pickup,
    LocationEntity? destination,
    DateTime? calculatedAt,
    String? routingEngine,
    Map<String, dynamic>? metadata,
  }) {
    return TripEntity(
      routePoints: routePoints ?? this.routePoints,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      pickup: pickup ?? this.pickup,
      destination: destination ?? this.destination,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      routingEngine: routingEngine ?? this.routingEngine,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'TripEntity(distance: ${distanceKm.toStringAsFixed(2)}km, duration: ${durationMinutes}min, points: ${routePoints.length}, engine: ${routingEngine ?? "unknown"})';
  }
}
