import '../../domain/entities/oferta_viaje_entity.dart';
import '../../domain/entities/driver_entity.dart';
import 'driver_model.dart';

class ConductorModel extends Conductor {
  ConductorModel({
    required String id,
    required String nombre,
    required String telefono,
    required double calificacion,
  }) : super(
          id: id,
          nombre: nombre,
          telefono: telefono,
          calificacion: calificacion,
        );

  factory ConductorModel.fromJson(Map<String, dynamic> json) {
    return ConductorModel(
      id: json['id'],
      nombre: json['nombre'],
      telefono: json['telefono'],
      calificacion: json['calificacion'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'calificacion': calificacion,
    };
  }
}

class OfertaViajeModel extends OfertaViaje {
  OfertaViajeModel({
    required String ofertaId,
    required DriverEntity conductor,
    required double tarifaPropuesta,
    required String mensaje,
    required String tiempoEstimado,
    required String distanciaConductor,
    required String estado,
    required DateTime fechaOferta,
  }) : super(
          ofertaId: ofertaId,
          conductor: conductor,
          tarifaPropuesta: tarifaPropuesta,
          mensaje: mensaje,
          tiempoEstimado: tiempoEstimado,
          distanciaConductor: distanciaConductor,
          estado: estado,
          fechaOferta: fechaOferta,
        );

  factory OfertaViajeModel.fromJson(Map<String, dynamic> json) {
    return OfertaViajeModel(
      ofertaId: json['oferta_id'],
      conductor: DriverModel.fromJson(json['conductor']),
      tarifaPropuesta: json['tarifa_propuesta'].toDouble(),
      mensaje: json['mensaje'],
      tiempoEstimado: json['tiempo_estimado'],
      distanciaConductor: json['distancia_conductor'],
      estado: json['estado'],
      fechaOferta: DateTime.parse(json['fecha_oferta']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'oferta_id': ofertaId,
      'conductor': (conductor as DriverModel).toJson(),
      'tarifa_propuesta': tarifaPropuesta,
      'mensaje': mensaje,
      'tiempo_estimado': tiempoEstimado,
      'distancia_conductor': distanciaConductor,
      'estado': estado,
      'fecha_oferta': fechaOferta.toIso8601String(),
    };
  }
}

class OfertasViajeResponseModel extends OfertasViajeResponse {
  OfertasViajeResponseModel({
    required String rideId,
    required List<OfertaViaje> ofertas,
    required int totalOfertas,
  }) : super(
          rideId: rideId,
          ofertas: ofertas,
          totalOfertas: totalOfertas,
        );

  factory OfertasViajeResponseModel.fromJson(Map<String, dynamic> json) {
    return OfertasViajeResponseModel(
      rideId: json['rideId'],
      ofertas: (json['offers'] as List)
          .map((oferta) => OfertaViajeModel.fromJson(oferta))
          .toList(),
      totalOfertas: json['totalOffers'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rideId': rideId,
      'offers': ofertas.map((oferta) => (oferta as OfertaViajeModel).toJson()).toList(),
      'totalOffers': totalOfertas,
    };
  }
} 