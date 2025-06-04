import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../viewmodels/map_viewmodel.dart';

/// Widget del campo de búsqueda de destino con X para limpiar destino seleccionado
class DestinationSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final VoidCallback onClear;
  final bool showClearButton;

  const DestinationSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
    required this.showClearButton,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MapViewModel>(
      builder: (context, mapViewModel, child) {
        // Determinar el estado del campo
        final bool hasDestination = mapViewModel.hasDestinationLocation;
        final String displayText =
            hasDestination
                ? (mapViewModel.destinationLocation!.address ??
                    'Destino seleccionado')
                : controller.text;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF505050), // Gris más claro
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF606060), width: 1),
          ),
          child:
              hasDestination
                  ? _buildSelectedDestinationField(context, mapViewModel)
                  : _buildSearchField(),
        );
      },
    );
  }

  /// Campo cuando hay destino seleccionado (mostrar nombre + X para borrar)
  Widget _buildSelectedDestinationField(
    BuildContext context,
    MapViewModel mapViewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icono de lugar
          const Icon(Icons.place, color: AppColors.secondary, size: 20),
          const SizedBox(width: 12),

          // Nombre del destino seleccionado
          Expanded(
            child: Text(
              mapViewModel.destinationLocation!.address ??
                  'Destino seleccionado',
              style: AppTextStyles.interInput.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // X para borrar destino
          GestureDetector(
            onTap: () => _clearDestination(context, mapViewModel),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, color: AppColors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  /// Campo de búsqueda normal (cuando no hay destino seleccionado)
  Widget _buildSearchField() {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      style: AppTextStyles.interInput.copyWith(color: AppColors.white),
      decoration: InputDecoration(
        hintText: 'Destino',
        hintStyle: AppTextStyles.interInputHint.copyWith(
          color: AppColors.white.withOpacity(0.6),
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(16),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.primary,
          size: 20,
        ),
        suffixIcon:
            showClearButton
                ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.white,
                    size: 18,
                  ),
                  onPressed: onClear,
                )
                : null,
      ),
      onChanged: onChanged,
    );
  }

  /// Limpiar destino seleccionado
  void _clearDestination(BuildContext context, MapViewModel mapViewModel) {
    // Limpiar destino en el ViewModel
    mapViewModel.clearDestination();

    // Limpiar también el campo de búsqueda
    controller.clear();

    // Ejecutar callback para limpiar búsqueda en el ViewModel de búsqueda
    onClear();

    // Enfocar el campo para continuar buscando
    focusNode.requestFocus();
  }
}
