import 'package:joya_express/data/models/user_model.dart';

class SendCodeResponse {
  final String telefono;
  final WhatsappInfo whatsapp;
  final List<String> instructions;
  final String provider;
  final DateTime timestamp;

  SendCodeResponse({
    required this.telefono,
    required this.whatsapp,
    required this.instructions,
    required this.provider,
    required this.timestamp,
  });

  factory SendCodeResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return SendCodeResponse(
      telefono: data['telefono'] ?? '',
      whatsapp: WhatsappInfo.fromJson(data['whatsapp'] ?? {}),
      instructions: List<String>.from(data['instructions'] ?? []),
      provider: data['provider'] ?? '',
      timestamp: DateTime.parse(data['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class WhatsappInfo {
  final String number;
  final String message;
  final String url;

  WhatsappInfo({
    required this.number,
    required this.message,
    required this.url,
  });

  factory WhatsappInfo.fromJson(Map<String, dynamic> json) {
    return WhatsappInfo(
      number: json['number'] ?? '',
      message: json['message'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class VerifyCodeResponse {
  final String message;
  final String tempToken;
  final String telefono;
  final bool userExists;

  VerifyCodeResponse({
    required this.message,
    required this.tempToken,
    required this.telefono,
    required this.userExists,
  });

  factory VerifyCodeResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return VerifyCodeResponse(
      message: data['message'] ?? '',
      tempToken: data['tempToken'] ?? '',
      telefono: data['telefono'] ?? '',
      userExists: data['userExists'] ?? false,
    );
  }
}

class LoginResponse {
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  LoginResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return LoginResponse(
      user: UserModel.fromJson(data['user'] ?? {}),
      accessToken: data['accessToken'] ?? '',
      refreshToken: data['refreshToken'] ?? '',
    );
  }
}