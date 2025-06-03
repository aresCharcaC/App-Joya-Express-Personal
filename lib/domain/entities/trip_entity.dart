import 'package:latlong2/latlong.dart';
import 'package:trip_routing/trip_routing.dart' as tr;
import './location_entity.dart';

/// Entidad que representa un viaje completo calculado
class TripEntity {
  final List<LatLng> routePoints;
  final double distanceKm;
  final int durationMinutes;
  final LocationEntity pickup;
  final LocationEntity destination;
  final DateTime calculatedAt;
  final tr.Trip? originalTrip; // Referencia al Trip original de trip_routing

  const TripEntity({
    required this.routePoints,
    required this.distanceKm,
    required this.durationMinutes,
    required this.pickup,
    required this.destination,
    required this.calculatedAt,
    this.originalTrip,
  });

  TripEntity copyWith({
    List<LatLng>? routePoints,
    double? distanceKm,
    int? durationMinutes,
    LocationEntity? pickup,
    LocationEntity? destination,
    DateTime? calculatedAt,
    tr.Trip? originalTrip,
  }) {
    return TripEntity(
      routePoints: routePoints ?? this.routePoints,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      pickup: pickup ?? this.pickup,
      destination: destination ?? this.destination,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      originalTrip: originalTrip ?? this.originalTrip,
    );
  }

  @override
  String toString() {
    return 'TripEntity(distance: ${distanceKm.toStringAsFixed(2)}km, duration: ${durationMinutes}min, points: ${routePoints.length})';
  }
}
