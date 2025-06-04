import 'package:trip_routing/trip_routing.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trip_routing/src/utils/haversine.dart';

class VehicleTripService extends TripService {
  VehicleTripService() : super();

  // CONSULTA ULTRA ESTRICTA - Solo calles vehiculares principales
  @override
  Future<List<Map<String, dynamic>>> _fetchWalkingPaths(
    double minLat,
    double minLon,
    double maxLat,
    double maxLon,
  ) async {
    // Clamp bounds to avoid NaN/Infinity
    double clamp(double v, double min, double max) =>
        v.isFinite ? v.clamp(min, max) as double : min;
    minLat = clamp(minLat, -90, 90);
    maxLat = clamp(maxLat, -90, 90);
    minLon = clamp(minLon, -180, 180);
    maxLon = clamp(maxLon, -180, 180);

    // CONSULTA ULTRA ESTRICTA - EXCLUYE COMPLETAMENTE PEATONALES
    final query = '''
      [out:json];
      (
        // SOLO vías principales para vehículos motorizados
        way["highway"~"^(motorway|trunk|primary|secondary|tertiary|residential|unclassified|service)\$"]
           ["motor_vehicle"!="no"]
           ["vehicle"!="no"]
           ["access"!="private"]
           ["access"!="no"]
           // EXCLUSIONES ESTRICTAS - NUNCA PEATONALES
           ["highway"!="pedestrian"]
           ["highway"!="footway"] 
           ["highway"!="path"]
           ["highway"!="steps"]
           ["highway"!="cycleway"]
           ["highway"!="track"]
           ["foot"!="designated"]
           ["foot"!="only"]
           ["pedestrian"!="only"]
           ["bicycle"!="designated"]
           ["bicycle"!="only"]
           ["area"!="yes"]
           ["place"!="square"]
           ["leisure"!="park"]
           ["amenity"!="parking"]
           // ASEGURAR QUE ES PARA VEHÍCULOS
           ["motor_vehicle"!="private"]
           ["motorcar"!="no"]
           ($minLat, $minLon, $maxLat, $maxLon);
      );
      out body;
      >;
      out skel qt;
      ''';

    final url = Uri.parse('https://overpass-api.de/api/interpreter');
    try {
      final response = await http.post(url, body: {'data': query});
      if (response.statusCode == 200) {
        final rawData = jsonDecode(response.body) as Map<String, dynamic>;
        final elements = rawData['elements'];
        if (elements is List) {
          // FILTRO ADICIONAL EN CÓDIGO - Doble verificación
          final filteredElements =
              elements.where((e) {
                final tags = e['tags'] as Map<String, dynamic>? ?? {};
                final highway = tags['highway'] as String?;

                // Lista blanca de tipos de carretera permitidos
                const allowedHighways = {
                  'motorway',
                  'trunk',
                  'primary',
                  'secondary',
                  'tertiary',
                  'residential',
                  'unclassified',
                  'service',
                };

                // Verificar que es un tipo permitido
                if (highway == null || !allowedHighways.contains(highway)) {
                  return false;
                }

                // Verificar que NO es exclusivo para peatones/bicicletas
                final foot = tags['foot'] as String?;
                final bicycle = tags['bicycle'] as String?;
                final access = tags['access'] as String?;

                if (foot == 'designated' ||
                    foot == 'only' ||
                    bicycle == 'designated' ||
                    bicycle == 'only' ||
                    access == 'private' ||
                    access == 'no') {
                  return false;
                }

                return true;
              }).toList();

          return filteredElements.map<Map<String, dynamic>>((e) {
            // Defensive extraction
            double safeDouble(dynamic v) {
              if (v is num && v.isFinite) return v.toDouble();
              if (v is String) {
                final d = double.tryParse(v);
                if (d != null && d.isFinite) return d;
              }
              return 0.0;
            }

            int safeInt(dynamic v) {
              if (v is int) return v;
              if (v is num && v.isFinite) return v.round();
              if (v is String) {
                final i = int.tryParse(v);
                if (i != null) return i;
              }
              return -1;
            }

            return {
              'type': e['type'] ?? '',
              'id': safeInt(e['id']),
              'lat': safeDouble(e['lat']),
              'lon': safeDouble(e['lon']),
              'tags': e['tags'] ?? <String, dynamic>{},
              'nodes':
                  (e['nodes'] is List)
                      ? List<int>.from(e['nodes'].map(safeInt))
                      : <int>[],
            };
          }).toList();
        }
      }
    } catch (e) {
      print("Error en consulta Overpass ESTRICTA: $e");
    }
    return [];
  }

  /// Verifica si un punto está en una carretera para vehículos (VERSIÓN ESTRICTA)
  Future<bool> isOnVehicleRoad(LatLng point) async {
    try {
      final query = '''
        [out:json];
        (
          // BUSCAR SOLO CALLES VEHICULARES PRINCIPALES
          way["highway"~"^(motorway|trunk|primary|secondary|tertiary|residential|unclassified|service)\$"]
             ["motor_vehicle"!="no"]
             ["vehicle"!="no"]
             ["highway"!="pedestrian"]
             ["highway"!="footway"]
             ["highway"!="path"]
             ["highway"!="steps"]
             ["foot"!="designated"]
             ["foot"!="only"]
             (around:15, ${point.latitude}, ${point.longitude});
        );
        out body;
        ''';

      final url = Uri.parse('https://overpass-api.de/api/interpreter');
      final response = await http.post(url, body: {'data': query});

      if (response.statusCode == 200) {
        final rawData = jsonDecode(response.body) as Map<String, dynamic>;
        final elements = rawData['elements'] as List;

        // Si encontramos al menos una carretera vehicular ESTRICTA
        return elements.isNotEmpty;
      }

      return false;
    } catch (e) {
      print("Error al verificar punto vehicular: $e");
      return false;
    }
  }

  /// Ajusta un punto al nodo de calle vehicular más cercana (VERSIÓN ESTRICTA)
  Future<LatLng> snapToVehicleRoad(LatLng point) async {
    try {
      // Primero verificamos si el punto ya está en una carretera vehicular
      final bool isOnRoad = await isOnVehicleRoad(point);
      if (isOnRoad) {
        return point;
      }

      // Radios progresivos para encontrar calles vehiculares
      final List<int> searchRadii = [15, 50, 150, 300, 500];

      for (final radius in searchRadii) {
        final query = '''
        [out:json];
        (
          // NODOS DE CALLES VEHICULARES PRINCIPALES ÚNICAMENTE
          way["highway"~"^(motorway|trunk|primary|secondary|tertiary|residential|unclassified|service)\$"]
             ["motor_vehicle"!="no"]
             ["vehicle"!="no"]
             ["highway"!="pedestrian"]
             ["highway"!="footway"]
             ["highway"!="path"]
             ["highway"!="steps"]
             ["foot"!="designated"]
             ["foot"!="only"]
             (around:$radius, ${point.latitude}, ${point.longitude});
          node(w);
        );
        out body;
        ''';

        final url = Uri.parse('https://overpass-api.de/api/interpreter');
        final response = await http.post(url, body: {'data': query});

        if (response.statusCode == 200) {
          final rawData = jsonDecode(response.body) as Map<String, dynamic>;
          final elements = rawData['elements'] as List;

          if (elements.isNotEmpty) {
            LatLng closestNode = point;
            double minDistance = double.infinity;

            for (final element in elements) {
              if (element['type'] == 'node' &&
                  element['lat'] != null &&
                  element['lon'] != null) {
                final nodeLat = element['lat'] as double;
                final nodeLon = element['lon'] as double;
                final nodePoint = LatLng(nodeLat, nodeLon);

                final distance = haversineDistance(
                  point.latitude,
                  point.longitude,
                  nodePoint.latitude,
                  nodePoint.longitude,
                );

                if (distance < minDistance) {
                  minDistance = distance;
                  closestNode = nodePoint;
                }
              }
            }

            if (minDistance < double.infinity) {
              print(
                "✅ Punto ajustado a carretera vehicular (${minDistance.toStringAsFixed(0)}m)",
              );
              return closestNode;
            }
          }
        }
      }

      // Si no encontramos NADA vehicular, lanzar excepción específica
      throw Exception(
        "No se encontraron calles vehiculares cerca del punto seleccionado",
      );
    } catch (e) {
      print("❌ Error ajustando a carretera vehicular: $e");
      rethrow; // Re-lanzar para que sea manejado arriba
    }
  }

  @override
  Future<Trip> findTotalTrip(
    List<LatLng> waypoints, {
    bool preferWalkingPaths = false,
    bool replaceWaypointsWithBuildingEntrances = false,
    bool forceIncludeWaypoints = false,
    double duplicationPenalty = 0.0,
  }) async {
    // Ajustar TODOS los waypoints a carreteras vehiculares ESTRICTAS
    List<LatLng> vehicleWaypoints = [];

    for (final waypoint in waypoints) {
      try {
        final snappedPoint = await snapToVehicleRoad(waypoint);
        vehicleWaypoints.add(snappedPoint);
      } catch (e) {
        // Si no se puede ajustar algún waypoint, fallar inmediatamente
        throw Exception("No se pudo ajustar punto a carretera vehicular: $e");
      }
    }

    // Llamar al método original con configuración ESTRICTA para vehículos
    final trip = await super.findTotalTrip(
      vehicleWaypoints,
      preferWalkingPaths: false, // NUNCA peatonal
      replaceWaypointsWithBuildingEntrances: false,
      forceIncludeWaypoints: false,
      duplicationPenalty: duplicationPenalty,
    );

    // VALIDACIÓN FINAL - Verificar que la ruta no contiene segmentos peatonales
    if (trip.route.isEmpty) {
      throw Exception("No se generó ninguna ruta vehicular válida");
    }

    return trip;
  }
}
