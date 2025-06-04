import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../domain/entities/place_entity.dart';
import '../viewmodels/destination_search_viewmodel.dart';
import 'location_suggestion_item_dark.dart';

/// Lista de resultados de búsqueda de destino (SIN títulos de sección)
class DestinationResultsList extends StatelessWidget {
  final Function(PlaceEntity) onSelectPlace;

  const DestinationResultsList({super.key, required this.onSelectPlace});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<DestinationSearchViewModel>(
        builder: (context, searchViewModel, child) {
          if (searchViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return Container(
            color: const Color(0xFF2D2D2D), // Fondo oscuro
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Lista de lugares SIN títulos
                if (searchViewModel.hasResults) ...[
                  const SizedBox(height: 8),

                  // Lista directa de lugares
                  ...searchViewModel.searchResults.map(
                    (place) => LocationSuggestionItemDark(
                      place: place,
                      onTap: () => _selectPlace(place, searchViewModel),
                      showCategory: true,
                    ),
                  ),
                ],

                // Mensaje cuando no hay resultados
                if (!searchViewModel.hasResults &&
                    searchViewModel.hasSearchQuery) ...[
                  const SizedBox(height: 60),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: AppColors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron resultados',
                          style: AppTextStyles.interBody.copyWith(
                            color: AppColors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
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

                // Mostrar mensaje sutil cuando no hay búsqueda (destinos recientes)
                if (!searchViewModel.hasSearchQuery &&
                    searchViewModel.hasResults) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      'Destinos recientes',
                      style: AppTextStyles.interCaption.copyWith(
                        color: AppColors.white.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Seleccionar lugar y agregarlo al historial
  void _selectPlace(
    PlaceEntity place,
    DestinationSearchViewModel searchViewModel,
  ) {
    // Agregar al historial reciente
    searchViewModel.addToRecentDestinations(place);

    // Ejecutar callback
    onSelectPlace(place);
  }
}
