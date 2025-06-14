# Migración de trip_routing a OSRM

## Resumen

Se ha completado la migración del sistema de routing de `trip_routing` (experimental) a **OSRM (Open Source Routing Machine)** para resolver los problemas de:

- ❌ No conoce nombres de calles
- ❌ No reconoce caminos
- ❌ Rutas no válidas
- ❌ No respeta calles de una dirección
- ❌ Se pasa las áreas verdes

## Cambios Realizados

### 1. Dependencias Actualizadas

**Antes (pubspec.yaml):**
```yaml
dependencies:
  trip_routing: ^0.0.13  # REMOVIDO
```

**Después (pubspec.yaml):**
```yaml
dependencies:
  # OSRM para routing - más confiable que trip_routing
  osrm: ^1.0.0
```

### 2. Nuevo Servicio OSRM

**Archivo creado:** `lib/data/services/osrm_routing_service.dart`

**Características:**
- ✅ Usa servidores OSRM públicos confiables
- ✅ Decodificación de polylines para rutas precisas
- ✅ Validaciones estrictas de rutas
- ✅ Manejo robusto de errores
- ✅ Snap-to-road usando OSRM Nearest API
- ✅ Cálculo preciso de distancias y tiempos

### 3. Entidad TripEntity Actualizada

**Antes:**
```dart
class TripEntity {
  final tr.Trip? originalTrip; // Dependencia de trip_routing
}
```

**Después:**
```dart
class TripEntity {
  final String? routingEngine; // 'OSRM', 'trip_routing', etc.
  final Map<String, dynamic>? metadata; // Metadatos flexibles
}
```

### 4. Repositorio Actualizado

**Archivo:** `lib/data/repositories_impl/routing_repository_impl.dart`

**Antes:**
```dart
class RoutingRepositoryImpl implements RoutingRepository {
  final EnhancedVehicleTripService _tripService; // trip_routing
}
```

**Después:**
```dart
class RoutingRepositoryImpl implements RoutingRepository {
  final OSRMRoutingService _osrmService; // OSRM
}
```

### 5. Inyección de Dependencias

**Archivo:** `lib/core/di/service_locator.dart`

**Agregado:**
```dart
// OSRM Routing Services
sl.registerLazySingleton<OSRMRoutingService>(() => OSRMRoutingService());

// Routing Repository
sl.registerLazySingleton<RoutingRepository>(
  () => RoutingRepositoryImpl(osrmService: sl<OSRMRoutingService>()),
);

// Use Case
sl.registerLazySingleton<CalculateVehicleRouteUseCase>(
  () => CalculateVehicleRouteUseCase(sl<RoutingRepository>()),
);
```

## Ventajas de OSRM

### 🚀 Confiabilidad
- Usa datos de OpenStreetMap actualizados
- Algoritmos de routing probados en producción
- Servidores públicos estables

### 🎯 Precisión
- Respeta direcciones de calles
- Evita áreas peatonales y parques
- Rutas optimizadas para vehículos

### 🔧 Funcionalidades
- **Route API**: Cálculo de rutas completas
- **Nearest API**: Snap-to-road preciso
- **Polyline encoding**: Rutas compactas y precisas

### 📊 Datos Precisos
- Distancias en metros
- Tiempos en segundos
- Geometría detallada de rutas

## Uso del Nuevo Sistema

### Ejemplo de Uso

```dart
// Inyectar el use case
final routeUseCase = sl<CalculateVehicleRouteUseCase>();

// Calcular ruta
final trip = await routeUseCase.execute(
  LocationEntity(
    coordinates: LatLng(-12.0464, -77.0428), // Lima, Perú
    address: "Plaza de Armas",
  ),
  LocationEntity(
    coordinates: LatLng(-12.1211, -77.0282), // Miraflores
    address: "Parque Kennedy",
  ),
);

// Resultado
print('Distancia: ${trip.distanceKm.toStringAsFixed(2)} km');
print('Duración: ${trip.durationMinutes} minutos');
print('Motor: ${trip.routingEngine}'); // "OSRM"
print('Puntos de ruta: ${trip.routePoints.length}');
```

### Snap to Road

```dart
final osrmService = sl<OSRMRoutingService>();

// Ajustar punto a carretera más cercana
final snappedPoint = await osrmService.snapToRoad(
  LatLng(-12.0464, -77.0428)
);

// Verificar si está cerca de carretera
final isNearRoad = await osrmService.isNearRoad(
  LatLng(-12.0464, -77.0428)
);
```

## Migración Gradual

El sistema mantiene compatibilidad con el código existente:

1. **Interfaz RoutingRepository**: Sin cambios
2. **TripEntity**: Retrocompatible con nuevos campos opcionales
3. **Use Cases**: Misma API pública

## Servidores OSRM Utilizados

### Servidor Principal
- **URL**: `https://router.project-osrm.org`
- **Mantenido por**: Proyecto OSRM oficial
- **Cobertura**: Mundial

### Servidor Alternativo
- **URL**: `https://routing.openstreetmap.de`
- **Mantenido por**: Comunidad OpenStreetMap
- **Cobertura**: Mundial

## Configuración de Timeouts

```dart
// Timeouts configurados
final response = await http.get(url).timeout(Duration(seconds: 15));
final snapResponse = await http.get(url).timeout(Duration(seconds: 10));
```

## Validaciones Implementadas

### 1. Validación de Coordenadas
- Latitud: -90° a 90°
- Longitud: -180° a 180°

### 2. Validación de Distancias
- Distancia mínima entre puntos
- Distancia máxima permitida

### 3. Validación de Rutas
- Ruta debe tener al menos 2 puntos
- Inicio y fin cerca de puntos solicitados (500m tolerancia)
- Ratio de distancia razonable vs distancia directa

## Manejo de Errores

```dart
try {
  final trip = await osrmService.calculateRoute(pickup, destination);
} catch (e) {
  if (e.toString().contains('OSRM Error')) {
    // Error específico de OSRM
  } else if (e.toString().contains('No se encontraron rutas')) {
    // No hay rutas disponibles
  } else {
    // Error de red o validación
  }
}
```

## Próximos Pasos

1. **Monitoreo**: Observar el rendimiento en producción
2. **Optimización**: Ajustar timeouts según necesidad
3. **Cache**: Implementar cache para rutas frecuentes
4. **Fallback**: Considerar servidor OSRM propio si es necesario

## Archivos Modificados

- ✅ `pubspec.yaml` - Dependencias actualizadas
- ✅ `lib/data/services/osrm_routing_service.dart` - Nuevo servicio OSRM
- ✅ `lib/domain/entities/trip_entity.dart` - Entidad actualizada
- ✅ `lib/data/repositories_impl/routing_repository_impl.dart` - Repositorio actualizado
- ✅ `lib/domain/usecases/calculate_vehicle_route_usecase.dart` - Use case creado
- ✅ `lib/core/di/service_locator.dart` - DI actualizada

## Archivos Mantenidos (Compatibilidad)

- 🔄 `lib/data/services/enhanced_vehicle_trip_service.dart` - Mantiene trip_routing como fallback
- 🔄 `lib/data/services/vehicle_trip_service.dart` - Preservado para compatibilidad
- 🔄 `lib/domain/repositories/routing_repository.dart` - Interfaz sin cambios

---

**✅ Migración Completada**: El sistema ahora usa OSRM como motor principal de routing, proporcionando rutas más precisas y confiables.
