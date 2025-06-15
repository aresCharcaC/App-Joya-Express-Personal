import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/driver_settings_viewmodel.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/constants/app_colors.dart';

/// DriverSettingsScreen
/// -------------------
/// Pantalla de configuración LOCAL para conductores
/// Configuración guardada en SharedPreferences (no en BD)
class DriverSettingsScreen extends StatelessWidget {
  const DriverSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DriverSettingsViewModel()..init(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Configuración", style: AppTextStyles.poppinsHeading2),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: Consumer<DriverSettingsViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Radio de búsqueda
                  _buildRadiusSection(viewModel),
                  const SizedBox(height: 24),

                  // Ordenamiento
                  _buildSortingSection(viewModel),
                  const SizedBox(height: 24),

                  // Filtros
                  _buildFiltersSection(viewModel),
                  const SizedBox(height: 32),

                  // Botón guardar
                  if (viewModel.hasChanges)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _saveSettings(context, viewModel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Guardar Configuración",
                          style: AppTextStyles.poppinsButton,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRadiusSection(DriverSettingsViewModel viewModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "📍 Radio de Búsqueda",
              style: AppTextStyles.poppinsHeading3.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Distancia máxima para recibir solicitudes",
              style: AppTextStyles.interBodySmall.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // Slider
            Row(
              children: [
                Text("${viewModel.searchRadiusKm.toStringAsFixed(1)} km"),
                Expanded(
                  child: Slider(
                    value: viewModel.searchRadiusKm,
                    min: 0.5,
                    max: 5.0,
                    divisions: 18,
                    activeColor: AppColors.primary,
                    onChanged: viewModel.setSearchRadius,
                  ),
                ),
                Text("5.0 km"),
              ],
            ),

            // Opciones rápidas
            Wrap(
              spacing: 8,
              children:
                  [0.5, 1.0, 1.5, 2.0, 3.0].map((radius) {
                    final isSelected =
                        (viewModel.searchRadiusKm - radius).abs() < 0.1;
                    return FilterChip(
                      label: Text("${radius.toStringAsFixed(1)} km"),
                      selected: isSelected,
                      onSelected: (_) => viewModel.setSearchRadius(radius),
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                    );
                  }).toList(),
            ),

            const SizedBox(height: 8),
            Text(
              "≈ ${_getDistanceDescription(viewModel.searchRadiusKm)}",
              style: AppTextStyles.interCaption.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortingSection(DriverSettingsViewModel viewModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "🔄 Ordenar Solicitudes Por",
              style: AppTextStyles.poppinsHeading3.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...SortOption.values.map((option) {
              return RadioListTile<SortOption>(
                title: Text(
                  _getSortOptionTitle(option),
                  style: AppTextStyles.interBody,
                ),
                subtitle: Text(
                  _getSortOptionDescription(option),
                  style: AppTextStyles.interBodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                value: option,
                groupValue: viewModel.sortOption,
                activeColor: AppColors.primary,
                onChanged: viewModel.setSortOption,
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection(DriverSettingsViewModel viewModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "🔍 Filtros",
              style: AppTextStyles.poppinsHeading3.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Filtro por precio mínimo
            SwitchListTile(
              title: Text(
                "Solo solicitudes con precio mínimo",
                style: AppTextStyles.interBody,
              ),
              subtitle: Text(
                "Filtrar por debajo de S/. ${viewModel.minPrice.toStringAsFixed(1)}",
                style: AppTextStyles.interBodySmall.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              value: viewModel.filterByMinPrice,
              activeColor: AppColors.primary,
              onChanged: viewModel.setFilterByMinPrice,
              contentPadding: EdgeInsets.zero,
            ),

            if (viewModel.filterByMinPrice) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text("S/. ${viewModel.minPrice.toStringAsFixed(1)}"),
                  Expanded(
                    child: Slider(
                      value: viewModel.minPrice,
                      min: 3.0,
                      max: 20.0,
                      divisions: 34,
                      activeColor: AppColors.primary,
                      onChanged: viewModel.setMinPrice,
                    ),
                  ),
                  Text("S/. 20.0"),
                ],
              ),
            ],

            const Divider(),

            // Notificaciones sonoras
            SwitchListTile(
              title: Text(
                "Notificaciones sonoras",
                style: AppTextStyles.interBody,
              ),
              subtitle: Text(
                "Reproducir sonido al recibir solicitudes",
                style: AppTextStyles.interBodySmall.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              value: viewModel.soundNotifications,
              activeColor: AppColors.primary,
              onChanged: viewModel.setSoundNotifications,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  String _getDistanceDescription(double km) {
    if (km <= 0.5) return "4-5 cuadras";
    if (km <= 1.0) return "8-10 cuadras";
    if (km <= 1.5) return "12-15 cuadras";
    if (km <= 2.0) return "16-20 cuadras";
    if (km <= 3.0) return "24-30 cuadras";
    return "área amplia";
  }

  String _getSortOptionTitle(SortOption option) {
    switch (option) {
      case SortOption.distance:
        return "🎯 Cercanía";
      case SortOption.price:
        return "💰 Precio";
      case SortOption.time:
        return "⏰ Tiempo de solicitud";
    }
  }

  String _getSortOptionDescription(SortOption option) {
    switch (option) {
      case SortOption.distance:
        return "Mostrar primero las solicitudes más cercanas";
      case SortOption.price:
        return "Mostrar primero las solicitudes con mejor precio";
      case SortOption.time:
        return "Mostrar primero las solicitudes más recientes";
    }
  }

  void _saveSettings(
    BuildContext context,
    DriverSettingsViewModel viewModel,
  ) async {
    final success = await viewModel.saveSettings();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Configuración guardada correctamente"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Error al guardar configuración"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
