import 'package:flutter/material.dart';
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';
import '../../../../domain/entities/user_entity.dart';

/// Widget que representa el encabezado del Drawer personalizado.
/// Muestra la foto de perfil, nombre y número de teléfono del usuario.
/// Si no hay usuario o foto, muestra un avatar por defecto.
class CustomDrawerHeader extends StatelessWidget {
  final UserEntity? user;// Datos del usuario a mostrar

  const CustomDrawerHeader({
    super.key,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        // Fondo con gradiente y bordes redondeados en la parte inferior
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Foto de perfil del usuario (o avatar por defecto)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: user?.profilePhoto != null
                      ? Image.network(
                          user!.profilePhoto!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultAvatar();
                          },
                        )
                      : _buildDefaultAvatar(),
                ),
              ),
              const SizedBox(height: 12),

              // Nombre del usuario (o "Usuario" si no hay datos
              Text(
                user?.fullName ?? 'Usuario',
                style: AppTextStyles.poppinsHeading3.copyWith(
                  color: AppColors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Número de teléfono
              Text(
                user?.phone ?? '',
                style: AppTextStyles.interBodySmall.copyWith(
                  color: AppColors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  /// Widget auxiliar para mostrar un avatar por defecto si no hay foto de perfil
  Widget _buildDefaultAvatar() {
    return Container(
      color: AppColors.greyLight,
      child: const Icon(
        Icons.person,
        size: 40,
        color: AppColors.grey,
      ),
    );
  }
}