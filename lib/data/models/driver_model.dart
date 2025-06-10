import 'package:joya_express/domain/entities/driver_entity.dart';

class DriverModel extends DriverEntity {
  DriverModel({
    required String id,
    required String dni,
    required String nombreCompleto,
    required String telefono,
    String? fotoPerfil,
    required String estado,
    required int totalViajes,
    double? ubicacionLat,
    double? ubicacionLng,
    required bool disponible,
    DateTime? fechaRegistro,
    DateTime? fechaActualizacion,
    List<DocumentoEntity>? documentos,
    List<VehiculoEntity>? vehiculos,
    List<String>? metodosPago,
    DateTime? fechaExpiracionBrevete,
    Map<String, String>? contactoEmergencia,
  }) : super(
          id: id,
          dni: dni,
          nombreCompleto: nombreCompleto,
          telefono: telefono,
          fotoPerfil: fotoPerfil,
          estado: estado,
          totalViajes: totalViajes,
          ubicacionLat: ubicacionLat,
          ubicacionLng: ubicacionLng,
          disponible: disponible,
          fechaRegistro: fechaRegistro,
          fechaActualizacion: fechaActualizacion,
          documentos: documentos,
          vehiculos: vehiculos,
          metodosPago: metodosPago,
          fechaExpiracionBrevete: fechaExpiracionBrevete,
          contactoEmergencia: contactoEmergencia,
        );

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
    );
  }
}

// Modelos anidados
class DocumentoModel extends DocumentoEntity {
  DocumentoModel({
    required String id,
    required String conductorId,
    required String fotoBrevete,
    required DateTime fechaSubida,
    DateTime? fechaExpiracion,
    required bool verificado,
    DateTime? fechaVerificacion,
  }) : super(
          id: id,
          conductorId: conductorId,
          fotoBrevete: fotoBrevete,
          fechaSubida: fechaSubida,
          fechaExpiracion: fechaExpiracion,
          verificado: verificado,
          fechaVerificacion: fechaVerificacion,
        );

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
}

class VehiculoModel extends VehiculoEntity {
  VehiculoModel({
    required String id,
    required String conductorId,
    required String placa,
    String? fotoLateral,
    required bool activo,
    required DateTime fechaRegistro,
  }) : super(
          id: id,
          conductorId: conductorId,
          placa: placa,
          fotoLateral: fotoLateral,
          activo: activo,
          fechaRegistro: fechaRegistro,
        );

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
}