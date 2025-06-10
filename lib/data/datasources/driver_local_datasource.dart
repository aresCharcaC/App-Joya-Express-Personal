import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/driver_entity.dart';

class DriverLocalDataSource {
  static const String _driverKey = 'current_driver';

  Future<void> saveDriver(DriverEntity driver) async {
    final prefs = await SharedPreferences.getInstance();
    final driverMap = {
      'id': driver.id,
      'dni': driver.dni,
      'nombre_completo': driver.nombreCompleto,
      'telefono': driver.telefono,
      'foto_perfil': driver.fotoPerfil,
      'estado': driver.estado,
      'total_viajes': driver.totalViajes,
      'ubicacion_lat': driver.ubicacionLat,
      'ubicacion_lng': driver.ubicacionLng,
      'disponible': driver.disponible,
      'fecha_registro': driver.fechaRegistro?.toIso8601String(),
      'fecha_actualizacion': driver.fechaActualizacion?.toIso8601String(),
      'metodos_pago': driver.metodosPago,
      'fecha_expiracion_brevete': driver.fechaExpiracionBrevete?.toIso8601String(),
      'contacto_emergencia': driver.contactoEmergencia,
      // Guardar listas de objetos como JSON
      'documentos': driver.documentos?.map((d) => {
        'id': d.id,
        'conductor_id': d.conductorId,
        'foto_brevete': d.fotoBrevete,
        'fecha_subida': d.fechaSubida.toIso8601String(),
        'fecha_expiracion': d.fechaExpiracion?.toIso8601String(),
        'verificado': d.verificado,
        'fecha_verificacion': d.fechaVerificacion?.toIso8601String(),
      }).toList(),
      'vehiculos': driver.vehiculos?.map((v) => {
        'id': v.id,
        'conductor_id': v.conductorId,
        'placa': v.placa,
        'foto_lateral': v.fotoLateral,
        'activo': v.activo,
        'fecha_registro': v.fechaRegistro.toIso8601String(),
      }).toList(),
    };
    await prefs.setString(_driverKey, jsonEncode(driverMap));
  }

  Future<DriverEntity?> getDriver() async {
    final prefs = await SharedPreferences.getInstance();
    final driverJson = prefs.getString(_driverKey);
    if (driverJson != null) {
      final driverMap = jsonDecode(driverJson);
      return DriverEntity(
        id: driverMap['id'] ?? '',
        dni: driverMap['dni'] ?? '',
        nombreCompleto: driverMap['nombre_completo'] ?? '',
        telefono: driverMap['telefono'] ?? '',
        fotoPerfil: driverMap['foto_perfil'],
        // NO pongas fotoLateral, fotoBrevete ni placa aquí
        estado: driverMap['estado'] ?? '',
        totalViajes: driverMap['total_viajes'] ?? 0,
        ubicacionLat: driverMap['ubicacion_lat'] != null ? (driverMap['ubicacion_lat'] as num).toDouble() : null,
        ubicacionLng: driverMap['ubicacion_lng'] != null ? (driverMap['ubicacion_lng'] as num).toDouble() : null,
        disponible: driverMap['disponible'] ?? false,
        fechaRegistro: driverMap['fecha_registro'] != null ? DateTime.tryParse(driverMap['fecha_registro']) : null,
        fechaActualizacion: driverMap['fecha_actualizacion'] != null ? DateTime.tryParse(driverMap['fecha_actualizacion']) : null,
        metodosPago: driverMap['metodos_pago'] != null ? List<String>.from(driverMap['metodos_pago']) : null,
        fechaExpiracionBrevete: driverMap['fecha_expiracion_brevete'] != null ? DateTime.tryParse(driverMap['fecha_expiracion_brevete']) : null,
        contactoEmergencia: driverMap['contacto_emergencia'] != null ? Map<String, String>.from(driverMap['contacto_emergencia']) : null,
        documentos: driverMap['documentos'] != null
            ? (driverMap['documentos'] as List)
                .map((d) => DocumentoEntity(
                      id: d['id'],
                      conductorId: d['conductor_id'],
                      fotoBrevete: d['foto_brevete'],
                      fechaSubida: DateTime.parse(d['fecha_subida']),
                      fechaExpiracion: d['fecha_expiracion'] != null ? DateTime.tryParse(d['fecha_expiracion']) : null,
                      verificado: d['verificado'] ?? false,
                      fechaVerificacion: d['fecha_verificacion'] != null ? DateTime.tryParse(d['fecha_verificacion']) : null,
                    ))
                .toList()
            : null,
        vehiculos: driverMap['vehiculos'] != null
            ? (driverMap['vehiculos'] as List)
                .map((v) => VehiculoEntity(
                      id: v['id'],
                      conductorId: v['conductor_id'],
                      placa: v['placa'],
                      fotoLateral: v['foto_lateral'],
                      activo: v['activo'] ?? true,
                      fechaRegistro: DateTime.parse(v['fecha_registro']),
                    ))
                .toList()
            : null,
      );
    }
    return null;
  }
}