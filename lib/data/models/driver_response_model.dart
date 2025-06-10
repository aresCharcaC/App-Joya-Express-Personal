import 'package:joya_express/data/models/driver_model.dart';

class DriverResponse {
  final bool success;
  final String message;
  final DriverModel conductor;
  final String? estado;
  final String? accessToken;

  DriverResponse({
    required this.success,
    required this.message,
    required this.conductor,
    this.estado,
    this.accessToken,
  });

  factory DriverResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return DriverResponse(
      success: json['success'] as bool,
      message: data['message'] as String,
      conductor: DriverModel.fromJson(data['conductor']),
      estado: data['estado'],
      accessToken: data['accessToken'],
    );
  }
}

class DriverLoginResponse {
  final bool success;
  final String message;
  final DriverModel conductor;
  final String accessToken;

  DriverLoginResponse({
    required this.success,
    required this.message,
    required this.conductor,
    required this.accessToken,
  });

  factory DriverLoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return DriverLoginResponse(
      success: json['success'] as bool,
      message: data['message'] as String,
      conductor: DriverModel.fromJson(data['conductor']),
      accessToken: data['accessToken'],
    );
  }
}