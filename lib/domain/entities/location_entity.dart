import 'package:latlong2/latlong.dart';

/// Entidad que representa una ubicación con coordenadas y detalles
class LocationEntity {
  final LatLng coordinates;
  final String? address;
  final String? name;
  final bool isCurrentLocation;

  const LocationEntity({
    required this.coordinates,
    this.address,
    this.name,
    this.isCurrentLocation = false,
  });

  LocationEntity copyWith({
    LatLng? coordinates,
    String? address,
    String? name,
    bool? isCurrentLocation,
  }) {
    return LocationEntity(
      coordinates: coordinates ?? this.coordinates,
      address: address ?? this.address,
      name: name ?? this.name,
      isCurrentLocation: isCurrentLocation ?? this.isCurrentLocation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationEntity &&
        other.coordinates == coordinates &&
        other.address == address &&
        other.name == name &&
        other.isCurrentLocation == isCurrentLocation;
  }

  @override
  int get hashCode {
    return coordinates.hashCode ^
        address.hashCode ^
        name.hashCode ^
        isCurrentLocation.hashCode;
  }

  @override
  String toString() {
    return 'LocationEntity(coordinates: $coordinates, address: $address, name: $name, isCurrentLocation: $isCurrentLocation)';
  }
}
