import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';

/// Widget para mostrar errores de rutas de manera elegante
class RouteErrorOverlay extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onClearLocations;
  final VoidCallback onDismiss;

  const RouteErrorOverlay({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    required this.onClearLocations,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isNoVehicleRouteError =
        errorMessage.contains(RouteConstants.noVehicleRouteError) ||
        errorMessage.contains(RouteConstants.overpassBackupFailedError) ||
        errorMessage.contains(RouteConstants.pedestrianOnlyError);

    return GestureDetector(
      onTap: onDismiss, // Cerrar tocando fuera
      child: Container(
        color: Colors.black54, // Fondo semitransparente
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Evitar que se cierre al tocar el contenido
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono de error
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color:
                          isNoVehicleRouteError
                              ? AppColors.warning.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isNoVehicleRouteError
                          ? Icons.directions_car_outlined
                          : Icons.error_outline,
                      size: 32,
                      color:
                          isNoVehicleRouteError
                              ? AppColors.warning
                              : AppColors.error,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Título del error
                  Text(
                    isNoVehicleRouteError
                        ? 'No hay camino vehicular válido'
                        : 'Error en la ruta',
                    style: AppTextStyles.poppinsHeading3.copyWith(
                      color:
                          isNoVehicleRouteError
                              ? AppColors.warning
                              : AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Mensaje principal
                  Text(
                    isNoVehicleRouteError
                        ? RouteConstants.selectDifferentPointsError
                        : _getSimplifiedErrorMessage(errorMessage),
                    style: AppTextStyles.interBody.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Botones de acción
                  if (isNoVehicleRouteError) ...[
                    // Para errores de no hay ruta vehicular
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onClearLocations,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Seleccionar otros puntos'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: onDismiss,
                        child: Text(
                          'Cerrar',
                          style: AppTextStyles.interBody.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Para otros errores
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onDismiss,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              side: BorderSide(color: AppColors.border),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Cerrar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onRetry,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Reintentar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Simplifica mensajes de error para el usuario
  String _getSimplifiedErrorMessage(String error) {
    if (error.contains(RouteConstants.timeoutError)) {
      return 'La conexión tardó demasiado. Intenta nuevamente.';
    } else if (error.contains(RouteConstants.networkError)) {
      return 'Sin conexión a internet. Verifica tu conexión.';
    } else if (error.contains(RouteConstants.noRoadNearbyError)) {
      return 'No hay calles cercanas. Selecciona otro punto.';
    } else if (error.contains(RouteConstants.tooFarError)) {
      return 'La distancia es demasiado larga para calcular la ruta.';
    } else if (error.contains(RouteConstants.sameLocationError)) {
      return 'El origen y destino son muy cercanos.';
    } else {
      return 'Hubo un problema calculando la ruta.';
    }
  }
}
