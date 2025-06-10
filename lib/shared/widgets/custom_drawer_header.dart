import 'package:flutter/material.dart';
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';
import '../../../../domain/entities/user_entity.dart';

/// Widget que representa el encabezado del Drawer personalizado.
/// Muestra la foto de perfil, nombre y número de teléfono del usuario.
/// Si no hay usuario o foto, muestra un avatar por defecto.
class CustomDrawerHeader extends StatefulWidget {
  final UserEntity? user;
  
  const CustomDrawerHeader({
    super.key,
    this.user,
  });
  
  @override
  State<CustomDrawerHeader> createState() => _CustomDrawerHeaderState();
}

class _CustomDrawerHeaderState extends State<CustomDrawerHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _gradientAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Configurar animación de gradiente
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Iniciar animación en loop
    _animationController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gradientAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.0,
                _gradientAnimation.value,
                1.0,
              ],
              colors: [
                AppColors.primary,
                const Color.fromARGB(255, 166, 27, 5),
                AppColors.primary.withOpacity(0.8),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Foto de perfil del usuario (o avatar por defecto)
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white,
                        width: 3,
                      ),
                      
                    ),
                    child: ClipOval(
                      child: widget.user?.profilePhoto != null
                          ? Image.network(
                              widget.user!.profilePhoto!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildDefaultAvatar();
                              },
                            )
                          : _buildDefaultAvatar(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Nombre del usuario (o "Usuario" si no hay datos)
                  Flexible(
                    child: Text(
                      widget.user?.fullName ?? 'Usuario',
                      style: AppTextStyles.poppinsHeading3.copyWith(
                        color: AppColors.white,
                        fontSize: 18, // Reducir tamaño si es necesario
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  
                  // Número de teléfono
                  Flexible(
                    child: Text(
                      widget.user?.phone ?? '',
                      style: AppTextStyles.interBodySmall.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                        fontSize: 13, // Asegurar tamaño consistente
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// Widget auxiliar para mostrar un avatar por defecto si no hay foto de perfil
  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person,
        size: 35,
        color: AppColors.grey,
      ),
    );
  }
}