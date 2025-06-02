class PhoneFormatter {
  static String formatToInternational(String phone) {
    // Remover espacios y caracteres especiales
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Si ya tiene código de país, devolverlo
    if (cleanPhone.startsWith('51') && cleanPhone.length == 11) {
      return '+$cleanPhone';
    }
    
    // Si es número peruano de 9 dígitos, agregar +51
    if (cleanPhone.length == 9) {
      return '+51$cleanPhone';
    }
    
    // Si tiene 8 dígitos, asumir que le falta un dígito al inicio
    if (cleanPhone.length == 8) {
      return '+519$cleanPhone';
    }
    
    return cleanPhone;
  }

  static String formatForDisplay(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanPhone.startsWith('51')) {
      cleanPhone = cleanPhone.substring(2);
    }
    
    if (cleanPhone.length == 9) {
      return '${cleanPhone.substring(0, 3)} ${cleanPhone.substring(3, 6)} ${cleanPhone.substring(6)}';
    }
    
    return phone;
  }

  static bool isValidPeruvianPhone(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Remover código de país si existe
    if (cleanPhone.startsWith('51')) {
      cleanPhone = cleanPhone.substring(2);
    }
    
    // Debe tener exactamente 9 dígitos y empezar con 9
    return cleanPhone.length == 9 && cleanPhone.startsWith('9');
  }
}