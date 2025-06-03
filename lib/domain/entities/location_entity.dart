import 'package:latlong2/latlong.dart';

/// Entidad que representa una ubicación con coordenadas y detalles
class LocationEntity {
  final LatLng coordinates;
  final String? address;
  final String? name;
  final bool isCurrentLocation;
  final bool isSnappedToRoad;

  const LocationEntity({
    required this.coordinates,
    this.address,
    this.name,
    this.isCurrentLocation = false,
    this.isSnappedToRoad = false,
  });

  LocationEntity copyWith({
    LatLng? coordinates,
    String? address,
    String? name,
    bool? isCurrentLocation,
    bool? isSnappedToRoad,
  }) {
    return LocationEntity(
      coordinates: coordinates ?? this.coordinates,
      address: address ?? this.address,
      name: name ?? this.name,
      isCurrentLocation: isCurrentLocation ?? this.isCurrentLocation,
      isSnappedToRoad: isSnappedToRoad ?? this.isSnappedToRoad,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationEntity &&
        other.coordinates == coordinates &&
        other.address == address &&
        other.name == name &&
        other.isCurrentLocation == isCurrentLocation &&
        other.isSnappedToRoad == isSnappedToRoad;
  }

  @override
  int get hashCode {
    return coordinates.hashCode ^
        address.hashCode ^
        name.hashCode ^
        isCurrentLocation.hashCode ^
        isSnappedToRoad.hashCode;
  }

  @override
  String toString() {
    return 'LocationEntity(coordinates: $coordinates, address: $address, name: $name, isCurrentLocation: $isCurrentLocation, isSnappedToRoad: $isSnappedToRoad)';
  }
}
