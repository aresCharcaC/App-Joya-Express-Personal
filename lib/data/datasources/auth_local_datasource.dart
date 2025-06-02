import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/**
 * servicio de almacenamiento local para datos de autenticación
 */
class AuthLocalDataSource {
  static const String _userKey = 'current_user';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tempTokenKey = 'temp_token';
  static const String _phoneKey = 'phone_number';
  
  //Guardar datos del usuario actual
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }
  //Obtener datos del usuario actual
  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    
    if (userString != null) {
      final userJson = json.decode(userString);
      return UserModel.fromJson(userJson);
    }
    
    return null;
  }
  //Guardar tokens de acceso y actualización
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  //Obtener tokens de acceso 
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }
  // Obtener token de actualización
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }
  //Guardar token temporal
  Future<void> saveTempToken(String tempToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tempTokenKey, tempToken);
  }
  //Obtener token temporal
  Future<String?> getTempToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tempTokenKey);
  }
  //Guardar número de teléfono
  Future<void> savePhoneNumber(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phoneKey, phone);
  }
  //Obtener número de teléfono
  Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }
  //Limpiar todos los datos de autenticación
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tempTokenKey);
    await prefs.remove(_phoneKey);
  }
}