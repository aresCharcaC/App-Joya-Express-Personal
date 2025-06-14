import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../domain/entities/place_entity.dart';
import '../viewmodels/destination_search_viewmodel.dart';
import 'location_suggestion_item_dark.dart';

/// Lista de resultados de búsqueda de destino (SIN títulos de sección)
/// Maneja tres estados principales:
/// 1. Loading - Muestra indicador de carga
/// 2. Resultados encontrados - Lista de lugares con opción "Destinos recientes"
/// 3. Sin resultados - Mensaje de estado vacío con sugerencias
class DestinationResultsList extends StatelessWidget {
  // Callback que se ejecuta cuando el usuario selecciona un lugar
  final Function(PlaceEntity) onSelectPlace;

  const DestinationResultsList({super.key, required this.onSelectPlace});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      // Consumer escucha cambios en el ViewModel de búsqueda
      // Se reconstruye automáticamente cuando cambia el estado
      child: Consumer<DestinationSearchViewModel>(
        builder: (context, searchViewModel, child) {
          
          // ESTADO 1: CARGA
          // Muestra spinner mientras se realiza la búsqueda
          if (searchViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          // CONTENEDOR PRINCIPAL con fondo oscuro consistente
          return Container(
            color: const Color(0xFF2D2D2D), // Mismo color que el header
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                
                // ESTADO 2: HAY RESULTADOS DE BÚSQUEDA
                // Renderiza la lista de lugares encontrados
                if (searchViewModel.hasResults) ...[
                  const SizedBox(height: 8),

                  // Mapea cada PlaceEntity a un widget LocationSuggestionItemDark
                  // El operador spread (...) expande la lista de widgets
                  ...searchViewModel.searchResults.map(
                    (place) => LocationSuggestionItemDark(
                      place: place,
                      // Callback personalizado que maneja selección + historial
                      onTap: () => _selectPlace(place, searchViewModel),
                      showCategory: true, // Muestra categoría del lugar
                    ),
                  ),
                ],

                // ESTADO 3: SIN RESULTADOS PERO HAY BÚSQUEDA ACTIVA
                // Pantalla de estado vacío con mensaje informativo
                if (!searchViewModel.hasResults &&
                    searchViewModel.hasSearchQuery) ...[
                  const SizedBox(height: 60), // Espaciado generoso
                  Center(
                    child: Column(
                      children: [
                        // Icono visual para el estado vacío
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: AppColors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        
                        // Mensaje principal de "no encontrado"
                        Text(
                          'No se encontraron resultados',
                          style: AppTextStyles.interBody.copyWith(
                            color: AppColors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Sugerencia de acción alternativa
                        Text(
                          'Prueba con otro término o selecciona en el mapa',
                          style: AppTextStyles.interCaption.copyWith(
                            color: AppColors.white.withOpacity(0.5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],

                // ESTADO 4: MODO "DESTINOS RECIENTES"
                // Se muestra cuando no hay búsqueda activa pero sí hay resultados
                // (presumiblemente del historial reciente)
                if (!searchViewModel.hasSearchQuery &&
                    searchViewModel.hasResults) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      'Destinos recientes', // Etiqueta sutil para contexto
                      style: AppTextStyles.interCaption.copyWith(
                        color: AppColors.white.withOpacity(0.4), // Muy sutil
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],

                // Espaciado inferior para mejor UX en scroll
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Maneja la selección de un lugar con dos responsabilidades:
  /// 1. Persiste el lugar en el historial reciente (ViewModel)
  /// 2. Notifica al componente padre a través del callback
  void _selectPlace(
    PlaceEntity place,
    DestinationSearchViewModel searchViewModel,
  ) {
    // Guardar en historial para futuras sesiones
    // (presumiblemente usa SharedPreferences o similar)
    searchViewModel.addToRecentDestinations(place);

    // Propagar la selección al componente padre
    // Esto probablemente cierra el modal y procesa el destino seleccionado
    onSelectPlace(place);
  }
}