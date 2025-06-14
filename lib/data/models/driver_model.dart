import 'package:joya_express/domain/entities/driver_entity.dart';

class DriverModel extends DriverEntity {
  DriverModel({
    required super.id,
    required super.dni,
    required super.nombreCompleto,
    required super.telefono,
    super.fotoPerfil,
    required super.estado,
    required super.totalViajes,
    super.ubicacionLat,
    super.ubicacionLng,
    required super.disponible,
    super.fechaRegistro,
    super.fechaActualizacion,
    super.documentos,
    super.vehiculos,
    super.metodosPago,
    super.fechaExpiracionBrevete,
    super.contactoEmergencia,
    super.calificacion,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'],
      dni: json['dni'],
      nombreCompleto: json['nombre_completo'],
      telefono: json['telefono'],
      fotoPerfil: json['foto_perfil'],
      estado: json['estado'],
      totalViajes: json['total_viajes'] ?? 0,
      ubicacionLat: json['ubicacion_lat'] != null ? double.tryParse(json['ubicacion_lat'].toString()) : null,
      ubicacionLng: json['ubicacion_lng'] != null ? double.tryParse(json['ubicacion_lng'].toString()) : null,
      disponible: json['disponible'] ?? false,
      fechaRegistro: json['fecha_registro'] != null ? DateTime.tryParse(json['fecha_registro']) : null,
      fechaActualizacion: json['fecha_actualizacion'] != null ? DateTime.tryParse(json['fecha_actualizacion']) : null,
      documentos: (json['documentos'] as List?)?.map((e) => DocumentoModel.fromJson(e)).toList(),
      vehiculos: (json['vehiculos'] as List?)?.map((e) => VehiculoModel.fromJson(e)).toList(),
      metodosPago: (json['metodos_pago'] as List?)?.map((e) => e.toString()).toList(),
      fechaExpiracionBrevete: json['fecha_expiracion_brevete'] != null ? DateTime.tryParse(json['fecha_expiracion_brevete']) : null,
      contactoEmergencia: json['contacto_emergencia'] != null ? Map<String, String>.from(json['contacto_emergencia']) : null,
      calificacion: json['calificacion']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dni': dni,
      'nombre_completo': nombreCompleto,
      'telefono': telefono,
      'foto_perfil': fotoPerfil,
      'estado': estado,
      'total_viajes': totalViajes,
      'ubicacion_lat': ubicacionLat,
      'ubicacion_lng': ubicacionLng,
      'disponible': disponible,
      'fecha_registro': fechaRegistro?.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion?.toIso8601String(),
      'documentos': documentos?.map((e) => (e as DocumentoModel).toJson()).toList(),
      'vehiculos': vehiculos?.map((e) => (e as VehiculoModel).toJson()).toList(),
      'metodos_pago': metodosPago,
      'fecha_expiracion_brevete': fechaExpiracionBrevete?.toIso8601String(),
      'contacto_emergencia': contactoEmergencia,
      'calificacion': calificacion,
    };
  }
}

// Modelos anidados
class DocumentoModel extends DocumentoEntity {
  DocumentoModel({
    required super.id,
    required super.conductorId,
    required super.fotoBrevete,
    required super.fechaSubida,
    super.fechaExpiracion,
    required super.verificado,
    super.fechaVerificacion,
  });

  factory DocumentoModel.fromJson(Map<String, dynamic> json) {
    return DocumentoModel(
      id: json['id'],
      conductorId: json['conductor_id'],
      fotoBrevete: json['foto_brevete'],
      fechaSubida: DateTime.parse(json['fecha_subida']),
      fechaExpiracion: json['fecha_expiracion'] != null ? DateTime.tryParse(json['fecha_expiracion']) : null,
      verificado: json['verificado'] ?? false,
      fechaVerificacion: json['fecha_verificacion'] != null ? DateTime.tryParse(json['fecha_verificacion']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conductor_id': conductorId,
      'foto_brevete': fotoBrevete,
      'fecha_subida': fechaSubida.toIso8601String(),
      'fecha_expiracion': fechaExpiracion?.toIso8601String(),
      'verificado': verificado,
      'fecha_verificacion': fechaVerificacion?.toIso8601String(),
    };
  }
}

class VehiculoModel extends VehiculoEntity {
  VehiculoModel({
    required super.id,
    required super.conductorId,
    required super.placa,
    super.fotoLateral,
    required super.activo,
    required super.fechaRegistro,
  });

  factory VehiculoModel.fromJson(Map<String, dynamic> json) {
    return VehiculoModel(
      id: json['id'],
      conductorId: json['conductor_id'],
      placa: json['placa'],
      fotoLateral: json['foto_lateral'],
      activo: json['activo'] ?? true,
      fechaRegistro: DateTime.parse(json['fecha_registro']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conductor_id': conductorId,
      'placa': placa,
      'foto_lateral': fotoLateral,
      'activo': activo,
      'fecha_registro': fechaRegistro.toIso8601String(),
    };
  }
}