import 'package:flutter/material.dart';
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_strings.dart';
import 'package:joya_express/core/constants/drawer_strings.dart';
import 'package:joya_express/presentation/modules/auth/Passenger/viewmodels/auth_viewmodel.dart';
import 'package:joya_express/presentation/modules/routes/app_routes.dart';
import 'package:joya_express/shared/widgets/confirmation_dialog.dart';
import 'package:joya_express/shared/widgets/custom_drawer_header.dart';
import 'package:joya_express/shared/widgets/drawer_menu_item.dart';
import 'package:provider/provider.dart';
import 'package:joya_express/presentation/modules/routes/app_routes.dart';
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
                  title: DrawerStrings.drawerProfile,
                  onTap: () => _navigateToProfile(context),
                ),
                const SizedBox(height: 8),
                // Opción: Métodos de pago
                DrawerMenuItem(
                  icon: Icons.payment_outlined,
                  title: DrawerStrings.drawerPaymentMethods,
                  onTap: () => _navigateToPaymentMethods(context),
                ),
                // Opción: Historial
                const SizedBox(height: 8),
                DrawerMenuItem(
                  icon: Icons.history_outlined,
                  title: DrawerStrings.drawerHistory,
                  onTap: () => _navigateToHistory(context),
                ),
                // Opción: Configuración
                const SizedBox(height: 8),
                DrawerMenuItem(
                  icon: Icons.settings_outlined,
                  title: DrawerStrings.drawerConfiguration,
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
                  title: DrawerStrings.drawerLogout,
                  iconColor: AppColors.primary,
                  textColor: AppColors.primary,
                  onTap: () => _showLogoutDialog(context),
                ),
                // Botón: Cambiar a modo conductor
                const SizedBox(height: 8),
                DrawerMenuItem(
                  icon: Icons.directions_car_filled_outlined,
                  title: DrawerStrings.drawerSwitchToDriver,
                  iconColor: Color(0xFFFF7043), 
                  textColor: Color(0xFFFF7043),
                  onTap: () {
                    Navigator.pop(context); // Cierra el Drawer
                    Navigator.pushNamed(context, 
                    AppRoutes.driverLogin);
                  },
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

  void _showLogoutDialog(BuildContext context) async {
  final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

  // Muestra el diálogo ANTES de cerrar el Drawer
  final confirmed = await showDialog<bool>(
    context: Navigator.of(context, rootNavigator: true).context,
    barrierDismissible: false,
    builder: (dialogContext) => ConfirmationDialog(
      title: AppStrings.logoutTitle,
      message: AppStrings.logoutMessage,
      confirmText: AppStrings.logoutConfirm,
      cancelText: AppStrings.logoutCancel,
      confirmButtonColor: AppColors.primary,
      onConfirm: () {
        Navigator.of(dialogContext).pop(true);
      },
    ),
  );

  // Ahora cierra el Drawer
  Navigator.pop(context);

  if (confirmed == true) {
    await authViewModel.logout();

    // Espera un frame para asegurar que todo está cerrado
    await Future.delayed(const Duration(milliseconds: 100));

    // Usa el contexto del root para navegar
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        AppRoutes.welcome,
        (route) => false,
      );
    }
  }
}
  // /// Realiza el logout y navega a la pantalla de login
  // void _performLogout(BuildContext context) {
  //   final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
  //   authViewModel.logout().then((_) {
  //     // Navegar al login y limpiar el stack
  //     Navigator.pushNamedAndRemoveUntil(
  //       context,
  //       '/login',
  //       (route) => false,
  //     );
  //   });
  // }
}