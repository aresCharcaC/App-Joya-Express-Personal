class RideValidationException implements Exception {
  final String message;
  final String? field;

  RideValidationException({required this.message, this.field});

  @override
  String toString() => 'RideValidationException: $message${field != null ? ' (Campo: $field)' : ''}';
} 