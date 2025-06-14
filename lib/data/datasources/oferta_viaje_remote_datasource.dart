import 'package:joya_express/core/network/api_client.dart';
import 'package:joya_express/core/network/api_endpoints.dart';
import 'package:joya_express/data/models/api_response_model.dart';
import 'package:joya_express/data/models/oferta_viaje_model.dart';

abstract class OfertaViajeRemoteDataSource {
  Future<OfertasViajeResponseModel> getOfertas(String rideId);
}

class OfertaViajeRemoteDataSourceImpl implements OfertaViajeRemoteDataSource {
  final ApiClient _apiClient;

  OfertaViajeRemoteDataSourceImpl(this._apiClient);

  @override
  Future<OfertasViajeResponseModel> getOfertas(String rideId) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.getRideOffers}$rideId');
      
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response,
        (json) => json,
      );

      if (!apiResponse.success) {
        throw Exception(apiResponse.error ?? 'Error al obtener ofertas');
      }

      return OfertasViajeResponseModel.fromJson(apiResponse.data!);
    } catch (e) {
      rethrow;
    }
  }
} 