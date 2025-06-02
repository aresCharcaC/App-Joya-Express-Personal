import 'package:flutter/material.dart';
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_strings.dart';
import 'package:joya_express/presentation/modules/auth/viewmodels/auth_viewmodel.dart';
import 'package:joya_express/shared/widgets/confirmation._dialog.dart';
import 'package:joya_express/shared/widgets/custom_drawer_header.dart';
import 'package:joya_express/shared/widgets/drawer_menu_item.dart';
import 'package:provider/provider.dart';

/**
 * AppDrawer
 * ---------
 * Widget que representa el Drawer lateral de la aplicación.
 * Muestra la información del usuario en la cabecera y una lista de opciones de menú.
 * Permite navegar a diferentes secciones y cerrar sesión.
 */
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [

          // Cabecera del Drawer con información del usuario (foto, nombre, teléfono)
          Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              return CustomDrawerHeader(
                user: authViewModel.currentUser,
              );
            },
          ),
          
          // Espaciado
          const SizedBox(height: 20),
          
          // Opciones del menú
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                // Opción: Perfil
                DrawerMenuItem(
                  icon: Icons.person_outline,
                  title: AppStrings.drawerProfile,
                  onTap: () => _navigateToProfile(context),
                ),
                const SizedBox(height: 8),
                // Opción: Métodos de pago
                DrawerMenuItem(
                  icon: Icons.payment_outlined,
                  title: AppStrings.drawerPaymentMethods,
                  onTap: () => _navigateToPaymentMethods(context),
                ),
                // Opción: Historial
                const SizedBox(height: 8),
                DrawerMenuItem(
                  icon: Icons.history_outlined,
                  title: AppStrings.drawerHistory,
                  onTap: () => _navigateToHistory(context),
                ),
                // Opción: Configuración
                const SizedBox(height: 8),
                DrawerMenuItem(
                  icon: Icons.settings_outlined,
                  title: AppStrings.drawerConfiguration,
                  onTap: () => _navigateToConfiguration(context),
                ),
                const SizedBox(height: 20),

                // Separador Visual
                const Divider(
                  color: AppColors.border,
                  thickness: 1,
                  indent: 8,
                  endIndent: 8,
                ),
                const SizedBox(height: 8),
                // Opción: Cerrar sesión
                DrawerMenuItem(
                  icon: Icons.logout_outlined,
                  title: AppStrings.drawerLogout,
                  iconColor: AppColors.primary,
                  textColor: AppColors.primary,
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  /// Navega a la pantalla de perfil del usuario
  void _navigateToProfile(BuildContext context) {
    Navigator.pop(context); // Cerrar drawer
    Navigator.pushNamed(context, '/profile');
  }
  /// Navega a métodos de pago (aún no implementado, muestra mensaje)

  void _navigateToPaymentMethods(BuildContext context) {
    Navigator.pop(context);
    // TODO: Implementar navegación a métodos de pago
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Métodos de pago - Próximamente')),
    );
  }
  /// Navega al historial (aún no implementado, muestra mensaje)

  void _navigateToHistory(BuildContext context) {
    Navigator.pop(context);
    // TODO: Implementar navegación al historial
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Historial - Próximamente')),
    );
  }
  /// Navega a configuración (aún no implementado, muestra mensaje)

  void _navigateToConfiguration(BuildContext context) {
    Navigator.pop(context);
    // TODO: Implementar navegación a configuración
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración - Próximamente')),
    );
  }
  /// Muestra el diálogo de confirmación para cerrar sesión

  void _showLogoutDialog(BuildContext context) {
    Navigator.pop(context); // Cerrar drawer primero
    
    ConfirmationDialog.showLogoutDialog(
      context,
      () => _performLogout(context),
    );
  }
  /// Realiza el logout y navega a la pantalla de login
  void _performLogout(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    authViewModel.logout().then((_) {
      // Navegar al login y limpiar el stack
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    });
  }
}