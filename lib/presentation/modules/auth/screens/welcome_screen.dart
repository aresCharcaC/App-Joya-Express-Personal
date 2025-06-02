import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_strings.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';
import 'package:joya_express/presentation/modules/auth/widgets/custom_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // Controlador para manejar múltiples SnackBars
  final List<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>> _activeSnackBars = [];
  
  @override
  void dispose() {
    // Limpiar SnackBars activos al salir de la pantalla
    _clearAllSnackBars();
    super.dispose();
  }

  void _clearAllSnackBars() {
    for (final controller in _activeSnackBars) {
      controller.close();
    }
    _activeSnackBars.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      // Espaciado superior adaptativo
                      SizedBox(height: screenHeight * 0.09),
                      
                      // Contenedor estilizado para la imagen del mototaxi
                      _buildMototaxiImageContainer(screenWidth),
                      
                      // Espaciado entre imagen y título
                      SizedBox(height: screenHeight * 0.03),
                      
                      // Título de la aplicación optimizado
                      _buildAppTitle(),
                    ],
                  ),
                  
                  // Sección de botones
                  _buildButtonSection(context, screenHeight),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMototaxiImageContainer(double screenWidth) {
    return Container(
      width: screenWidth * 0.7,
      height: screenWidth * 0.7,
      constraints: const BoxConstraints(
        maxWidth: 280,
        maxHeight: 280,
        minWidth: 200,
        minHeight: 200,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _buildMototaxiImage(),
      ),
    );
  }
//Mostramos la imagen aunque este cargando
  Widget _buildMototaxiImage() {
  return FutureBuilder<void>(
    future: _precacheImage(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return _buildErrorState();
      } else {
        return _buildImageWidget();
      }
    },
  );
}

  Future<void> _precacheImage() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }


  Widget _buildErrorState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primaryLight.withOpacity(0.1),
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_rounded,
              size: 80,
              color: AppColors.primary,
            ),
            SizedBox(height: 12),
            Text(
              '🚗',
              style: TextStyle(fontSize: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    return Image.asset(
      'assets/images/mototaxi.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error cargando imagen: $error');
        return _buildErrorState();
      },
    );
  }

  Widget _buildAppTitle() {
    return Hero(
      tag: 'app_title',
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.appName_1,
              style: AppTextStyles.poppinsHeading1.copyWith(
                fontSize: 49,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              AppStrings.appName_2,
              style: AppTextStyles.poppinsHeading1.copyWith(
                fontSize: 49,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonSection(BuildContext context, double screenHeight) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenHeight * 0.09),
      child: Column(
        children: [
          // Botón Registrarse con animación sutil
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (animationContext, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: CustomButton(
              text:AppStrings.register,
              backgroundColor: AppColors.primary,
              onPressed: () {
              Navigator.pushNamed(context, '/phone-input');
          },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Botón Iniciar Sesión con animación sutil
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (animationContext, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: CustomButton(
              text: AppStrings.login,
              backgroundColor: AppColors.grey,
              textColor: AppColors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
            ),
        ],
      ),
    );
  }
  // Método adicionales para navegación con feedback háptico y manejo de errores
  void _navigateWithImprovedFeedback(BuildContext context, String route, String buttonType) async {
    // Feedback háptico para mejor UX
    HapticFeedback.lightImpact();
    
    try {
      // Pequeño delay para mostrar el estado de loading y evitar navegación accidental
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Verificar si el widget sigue montado antes de navegar
      if (!mounted) return;
      
      // Intentar navegación - sin await porque es síncrono
      Navigator.pushNamed(context, route);
      
      // Si llegamos aquí, la navegación fue exitosa
      debugPrint('Navegación exitosa a: $route');
      
    } catch (e) {
      // Solo llegar aquí si hay un error real de navegación
      debugPrint('Error de navegación: $e');
      
      // Limpiar todos los SnackBars activos antes de mostrar uno nuevo
      _clearAllSnackBars();
      
      // Mostrar error inmediatamente
      _showStackedErrorSnackBar(context, route, e.toString());
      
    }
  }

  void _showStackedErrorSnackBar(BuildContext context, String route, String error) {
    // Crear timestamp único para identificar cada error
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    late ScaffoldFeatureController<SnackBar, SnackBarClosedReason> controller;
    controller = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: ValueKey('error_$timestamp'),
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Error de navegación',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'No se pudo acceder a $route',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 18),
              onPressed: () => controller.close(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.1 + (_activeSnackBars.length * 80),
          left: 16,
          right: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 6,
        action: SnackBarAction(
          label: 'Reintentar',
          textColor: Colors.white,
          onPressed: () {
            controller.close();
            _navigateWithImprovedFeedback(context, route, route.contains('phone') ? 'register' : 'login');
          },
        ),
      ),
    );

    // Agregar a la lista de SnackBars activos
    _activeSnackBars.add(controller);
    
    // Limpiar de la lista cuando se cierre
    controller.closed.then((_) {
      _activeSnackBars.remove(controller);
    });
    
    // Auto-limpiar después de cierto tiempo para evitar acumulación excesiva
    Future.delayed(const Duration(seconds: 5), () {
      if (_activeSnackBars.contains(controller)) {
        controller.close();
      }
    });
  }
}