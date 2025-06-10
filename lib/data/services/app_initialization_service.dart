
import 'package:joya_express/core/network/api_client.dart';

class AppInitializationService {
  static Future<void> initialize() async {
    // Cargar cookies de sesión guardadas
    final apiClient = ApiClient();
    await apiClient.loadCookiesFromStorage();
  }
}