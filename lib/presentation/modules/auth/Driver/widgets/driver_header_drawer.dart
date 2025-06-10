import 'package:flutter/material.dart';
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';
import 'package:joya_express/domain/entities/driver_entity.dart';

/// Widget que representa el encabezado del Drawer personalizado para conductores.
/// Muestra la foto de perfil, nombre completo y DNI del conductor.
/// Si no hay conductor o foto, muestra un avatar por defecto.
class DriverDrawerHeader extends StatefulWidget {
  final DriverEntity? driver;
  
  const DriverDrawerHeader({
    super.key,
    this.driver,
  });
  
  @override
  State<DriverDrawerHeader> createState() => _DriverDrawerHeaderState();
}

class _DriverDrawerHeaderState extends State<DriverDrawerHeader>
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
                // Colores específicos para conductores (más orientados al transporte)
                const Color(0xFF2E7D32), // Verde oscuro
                const Color(0xFF4CAF50), // Verde medio
                const Color(0xFF2E7D32).withOpacity(0.8), // Verde oscuro con opacidad
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
                  // Status indicator y foto de perfil
                  Stack(
                    children: [
                      // Foto de perfil del conductor (o avatar por defecto)
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
                          child: widget.driver?.fotoPerfil?.isNotEmpty == true
                              ? Image.network(
                                  widget.driver!.fotoPerfil!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildDefaultAvatar();
                                  },
                                )
                              : _buildDefaultAvatar(),
                        ),
                      ),
                      // Indicador de disponibilidad
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: (widget.driver?.disponible ?? false) 
                                ? Colors.green 
                                : Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Nombre del conductor (o "Conductor" si no hay datos)
                  Flexible(
                    child: Text(
                      widget.driver?.nombreCompleto ?? 'Conductor',
                      style: AppTextStyles.poppinsHeading2.copyWith(
                        color: AppColors.white,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  
                  // DNI del conductor
                  Flexible(
                    child: Text(
                      'DNI: ${widget.driver?.dni ?? 'N/A'}',
                      style: AppTextStyles.interBodySmall.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Estado de disponibilidad
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: (widget.driver?.disponible ?? false) 
                          ? Colors.green.withOpacity(0.3)
                          : Colors.red.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (widget.driver?.disponible ?? false) 
                            ? Colors.green 
                            : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      (widget.driver?.disponible ?? false) ? 'Disponible' : 'Ocupado',
                      style: AppTextStyles.interCaption.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
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
        Icons.drive_eta, // Ícono específico para conductores
        size: 35,
        color: AppColors.grey,
      ),
    );
  }
}