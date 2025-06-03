import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Servicio actualizado para obtener nombres de calles usando OpenStreetMap
class GeocodingService {
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';

  /// Obtiene el nombre de la calle desde coordenadas (ACTUALIZADO)
  static Future<String?> getStreetNameFromCoordinates(
    LatLng coordinates,
  ) async {
    try {
      final url = Uri.parse(
        '$_nominatimBaseUrl/reverse?format=json&lat=${coordinates.latitude}&lon=${coordinates.longitude}&zoom=18&addressdetails=1&accept-language=es',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'JoyaExpressApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['address'] != null) {
          final address = data['address'];

          // Buscar nombre de calle en orden de prioridad
          String? streetName =
              address['road'] ??
              address['street'] ??
              address['avenue'] ??
              address['highway'] ??
              address['pedestrian'];

          if (streetName != null) {
            // Limpiar y formatear el nombre
            streetName = _formatStreetName(streetName);

            // Agregar número de casa si existe
            final houseNumber = address['house_number'];
            if (houseNumber != null) {
              return '$streetName $houseNumber';
            }

            return streetName;
          }

          // Fallback: usar suburb o neighbourhood
          final area =
              address['suburb'] ??
              address['neighbourhood'] ??
              address['district'];
          if (area != null) {
            return area;
          }
        }
      }
    } catch (e) {
      print('Error obteniendo nombre de calle: $e');
    }

    return null; // No se pudo obtener nombre
  }

  /// Formatea el nombre de la calle para mejor presentación
  static String _formatStreetName(String streetName) {
    // Reemplazar abreviaciones comunes en español
    streetName = streetName
        .replaceAll('Av.', 'Avenida')
        .replaceAll('Jr.', 'Jirón')
        .replaceAll('Ca.', 'Calle')
        .replaceAll('Pje.', 'Pasaje')
        .replaceAll('Psje.', 'Pasaje');

    // Capitalizar primera letra de cada palabra
    return streetName
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  /// Obtiene información completa de dirección (para casos especiales)
  static Future<Map<String, String?>> getFullAddressInfo(
    LatLng coordinates,
  ) async {
    try {
      final url = Uri.parse(
        '$_nominatimBaseUrl/reverse?format=json&lat=${coordinates.latitude}&lon=${coordinates.longitude}&zoom=18&addressdetails=1&accept-language=es',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'JoyaExpressApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'] ?? {};

        return {
          'street': address['road'] ?? address['street'],
          'house_number': address['house_number'],
          'suburb': address['suburb'] ?? address['neighbourhood'],
          'district': address['district'],
          'city': address['city'] ?? address['town'],
          'state': address['state'],
        };
      }
    } catch (e) {
      print('Error obteniendo información completa: $e');
    }

    return {};
  }

  /// Verifica si las coordenadas están en Arequipa
  static bool isInArequipa(LatLng coordinates) {
    // Bounds aproximados de Arequipa metropolitana
    const double minLat = -16.5;
    const double maxLat = -16.3;
    const double minLng = -71.7;
    const double maxLng = -71.4;

    return coordinates.latitude >= minLat &&
        coordinates.latitude <= maxLat &&
        coordinates.longitude >= minLng &&
        coordinates.longitude <= maxLng;
  }
}
