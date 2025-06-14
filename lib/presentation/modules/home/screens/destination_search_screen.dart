import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/place_entity.dart';
import '../../../../domain/entities/location_entity.dart';
import '../viewmodels/destination_search_viewmodel.dart';
import '../viewmodels/map_viewmodel.dart';
import '../widgets/destination_modal_header.dart';
import '../widgets/origin_field_widget.dart';
import '../widgets/destination_search_field.dart';
import '../widgets/select_on_map_button.dart';
import '../widgets/destination_results_list.dart';
import 'map_selection_screen.dart';

/// Modal de búsqueda de destino que cubre 90% de la pantalla (SIN botón X)
class DestinationSearchScreen extends StatefulWidget {
  const DestinationSearchScreen({super.key});

  @override
  State<DestinationSearchScreen> createState() =>
      _DestinationSearchScreenState();
}

class _DestinationSearchScreenState extends State<DestinationSearchScreen> {
  late DestinationSearchViewModel _searchViewModel;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchViewModel = DestinationSearchViewModel();
    _searchViewModel.initialize();

    // Enfocar automáticamente el campo de búsqueda
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _searchViewModel,
      child: GestureDetector(
        // Cerrar modal tocando fuera (en el 10% que no cubre)
        onTap: () => Navigator.pop(context),
        child: Scaffold(
          backgroundColor: Colors.black26, // Fondo semitransparente
          body: GestureDetector(
            // Evitar que el modal se cierre al tocar dentro de él
            onTap: () {},
            child: Container(
              margin: EdgeInsets.only(
                top:
                    MediaQuery.of(context).size.height *
                    0.1, // 10% desde arriba
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF2D2D2D), // Color oscuro
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Header minimalista (SIN botón X)
                  const DestinationModalHeader(),

                  // Campo de origen (solo lectura)
                  const OriginFieldWidget(),

                  // Campo de búsqueda de destino
                  DestinationSearchField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: (value) {
                      _searchViewModel.searchPlaces(value);
                      setState(() {}); // Para actualizar botón clear
                    },
                    onClear: () {
                      _searchController.clear();
                      _searchViewModel.clearSearch();
                      setState(() {});
                    },
                    showClearButton: _searchController.text.isNotEmpty,
                  ),

                  // Botón "Seleccionar en el mapa" (limpio, sin recuadro)
                  SelectOnMapButton(onTap: _openMapSelection),

                  // Lista de resultados (destinos recientes o autocompletado)
                  DestinationResultsList(onSelectPlace: _selectPlace),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Seleccionar un lugar de la lista
  void _selectPlace(PlaceEntity place) {
    final mapViewModel = Provider.of<MapViewModel>(context, listen: false);

    // Convertir PlaceEntity a LocationEntity
    final destination = LocationEntity(
      coordinates: place.coordinates,
      address: place.name,
      name: place.name,
      isCurrentLocation: false,
    );

    // Establecer destino en el mapa
    mapViewModel.setDestinationLocation(destination);

    // Cerrar modal
    Navigator.pop(context);
  }

  /// Abrir pantalla de selección en mapa
  void _openMapSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapSelectionScreen()),
    ).then((selectedLocation) {
      if (selectedLocation != null && selectedLocation is LocationEntity) {
        final mapViewModel = Provider.of<MapViewModel>(context, listen: false);
        mapViewModel.setDestinationLocation(selectedLocation);
        Navigator.pop(context); // Cerrar modal de búsqueda
      }
    });
  }
}
