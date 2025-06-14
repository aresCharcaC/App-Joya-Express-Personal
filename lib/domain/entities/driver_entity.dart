class DriverEntity {
  final String id;
  final String dni;
  final String nombreCompleto;
  final String telefono;
  final String? fotoPerfil;
  final String estado;
  final int totalViajes;
  final double? ubicacionLat;
  final double? ubicacionLng;
  final bool disponible;
  final DateTime? fechaRegistro;
  final DateTime? fechaActualizacion;
  final List<DocumentoEntity>? documentos;
  final List<VehiculoEntity>? vehiculos;
  final List<String>? metodosPago;
  final DateTime? fechaExpiracionBrevete;
  final Map<String, String>? contactoEmergencia;
  final double calificacion;

  DriverEntity({
    required this.id,
    required this.dni,
    required this.nombreCompleto,
    required this.telefono,
    this.fotoPerfil,
    required this.estado,
    required this.totalViajes,
    this.ubicacionLat,
    this.ubicacionLng,
    required this.disponible,
    this.fechaRegistro,
    this.fechaActualizacion,
    this.documentos,
    this.vehiculos,
    this.metodosPago,
    this.fechaExpiracionBrevete,
    this.contactoEmergencia,
    this.calificacion = 0.0,
  });

  // Método copyWith para crear copias con campos modificados
  DriverEntity copyWith({
    String? id,
    String? dni,
    String? nombreCompleto,
    String? telefono,
    String? fotoPerfil,
    String? estado,
    int? totalViajes,
    double? ubicacionLat,
    double? ubicacionLng,
    bool? disponible,
    DateTime? fechaRegistro,
    DateTime? fechaActualizacion,
    List<DocumentoEntity>? documentos,
    List<VehiculoEntity>? vehiculos,
    List<String>? metodosPago,
    DateTime? fechaExpiracionBrevete,
    Map<String, String>? contactoEmergencia,
    double? calificacion,
  }) {
    return DriverEntity(
      id: id ?? this.id,
      dni: dni ?? this.dni,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      telefono: telefono ?? this.telefono,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      estado: estado ?? this.estado,
      totalViajes: totalViajes ?? this.totalViajes,
      ubicacionLat: ubicacionLat ?? this.ubicacionLat,
      ubicacionLng: ubicacionLng ?? this.ubicacionLng,
      disponible: disponible ?? this.disponible,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      documentos: documentos ?? this.documentos,
      vehiculos: vehiculos ?? this.vehiculos,
      metodosPago: metodosPago ?? this.metodosPago,
      fechaExpiracionBrevete: fechaExpiracionBrevete ?? this.fechaExpiracionBrevete,
      contactoEmergencia: contactoEmergencia ?? this.contactoEmergencia,
      calificacion: calificacion ?? this.calificacion,
    );
  }
}

class DocumentoEntity {
  final String id;
  final String conductorId;
  final String fotoBrevete;
  final DateTime fechaSubida;
  final DateTime? fechaExpiracion;
  final bool verificado;
  final DateTime? fechaVerificacion;

  DocumentoEntity({
    required this.id,
    required this.conductorId,
    required this.fotoBrevete,
    required this.fechaSubida,
    this.fechaExpiracion,
    required this.verificado,
    this.fechaVerificacion,
  });

  DocumentoEntity copyWith({
    String? id,
    String? conductorId,
    String? fotoBrevete,
    DateTime? fechaSubida,
    DateTime? fechaExpiracion,
    bool? verificado,
    DateTime? fechaVerificacion,
  }) {
    return DocumentoEntity(
      id: id ?? this.id,
      conductorId: conductorId ?? this.conductorId,
      fotoBrevete: fotoBrevete ?? this.fotoBrevete,
      fechaSubida: fechaSubida ?? this.fechaSubida,
      fechaExpiracion: fechaExpiracion ?? this.fechaExpiracion,
      verificado: verificado ?? this.verificado,
      fechaVerificacion: fechaVerificacion ?? this.fechaVerificacion,
    );
  }
}

class VehiculoEntity {
  final String id;
  final String conductorId;
  final String placa;
  final String? fotoLateral;
  final bool activo;
  final DateTime fechaRegistro;

  VehiculoEntity({
    required this.id,
    required this.conductorId,
    required this.placa,
    this.fotoLateral,
    required this.activo,
    required this.fechaRegistro,
  });

  VehiculoEntity copyWith({
    String? id,
    String? conductorId,
    String? placa,
    String? fotoLateral,
    bool? activo,
    DateTime? fechaRegistro,
  }) {
    return VehiculoEntity(
      id: id ?? this.id,
      conductorId: conductorId ?? this.conductorId,
      placa: placa ?? this.placa,
      fotoLateral: fotoLateral ?? this.fotoLateral,
      activo: activo ?? this.activo,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }
}