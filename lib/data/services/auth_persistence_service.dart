import 'package:shared_preferences/shared_preferences.dart';

class AuthPersistenceService {
  static const String _phoneNumberKey = 'auth_flow_phone';
  static const String _tempTokenKey = 'auth_flow_temp_token';
  static const String _verificationTokenKey = 'auth_flow_verification_token';
  static const String _timestampKey = 'auth_flow_timestamp';
  static const String _stepKey = 'auth_flow_step';

  // Guardar estado completo del flujo
  static Future<void> saveAuthFlowState({
    String? phoneNumber,
    String? tempToken,
    String? verificationToken,
    String? currentStep,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    if (phoneNumber != null) {
      await prefs.setString(_phoneNumberKey, phoneNumber);
    }
    if (tempToken != null) {
      await prefs.setString(_tempTokenKey, tempToken);
    }
    if (verificationToken != null) {
      await prefs.setString(_verificationTokenKey, verificationToken);
    }
    if (currentStep != null) {
      await prefs.setString(_stepKey, currentStep);
    }
    
    await prefs.setInt(_timestampKey, timestamp);
    
    print('AuthFlow - Estado guardado: phone=$phoneNumber, step=$currentStep, timestamp=$timestamp');
  }

  // Recuperar estado completo
  static Future<Map<String, String?>> getAuthFlowState() async {
    final prefs = await SharedPreferences.getInstance();
    
    final state = {
      'phoneNumber': prefs.getString(_phoneNumberKey),
      'tempToken': prefs.getString(_tempTokenKey),
      'verificationToken': prefs.getString(_verificationTokenKey),
      'currentStep': prefs.getString(_stepKey),
      'timestamp': prefs.getInt(_timestampKey)?.toString(),
    };
    
    print('AuthFlow - Estado recuperado: $state');
    return state;
  }

  // Verificar si el estado es válido (no expirado)
  static Future<bool> isStateValid({int maxAgeMinutes = 30}) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_timestampKey);
    
    if (timestamp == null) return false;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final ageMinutes = (now - timestamp) / (1000 * 60);
    
    final isValid = ageMinutes <= maxAgeMinutes;
    print('AuthFlow - Estado válido: $isValid (edad: ${ageMinutes.toStringAsFixed(1)} min)');
    
    return isValid;
  }

  // Limpiar estado específico
  static Future<void> clearAuthFlowState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_phoneNumberKey);
    await prefs.remove(_tempTokenKey);
    await prefs.remove(_verificationTokenKey);
    await prefs.remove(_timestampKey);
    await prefs.remove(_stepKey);
    print('AuthFlow - Estado limpiado');
  }

  // Métodos específicos para compatibilidad
  static Future<void> savePhoneNumber(String phone) async {
    await saveAuthFlowState(phoneNumber: phone, currentStep: 'phone_sent');
  }

  static Future<void> saveTempToken(String token) async {
    await saveAuthFlowState(tempToken: token, currentStep: 'code_verified');
  }
}
