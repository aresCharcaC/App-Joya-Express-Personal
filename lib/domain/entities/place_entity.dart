import 'package:latlong2/latlong.dart';

/// Entidad que representa un lugar guardado con nombre y coordenadas
class PlaceEntity {
  final String id;
  final String name;
  final String? description;
  final LatLng coordinates;
  final String category;
  final bool isPopular;

  const PlaceEntity({
    required this.id,
    required this.name,
    this.description,
    required this.coordinates,
    required this.category,
    this.isPopular = false,
  });

  PlaceEntity copyWith({
    String? id,
    String? name,
    String? description,
    LatLng? coordinates,
    String? category,
    bool? isPopular,
  }) {
    return PlaceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coordinates: coordinates ?? this.coordinates,
      category: category ?? this.category,
      isPopular: isPopular ?? this.isPopular,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlaceEntity &&
        other.id == id &&
        other.name == name &&
        other.coordinates == coordinates;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ coordinates.hashCode;
  }

  @override
  String toString() {
    return 'PlaceEntity(id: $id, name: $name, coordinates: $coordinates, category: $category)';
  }
}
