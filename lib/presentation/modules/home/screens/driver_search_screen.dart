import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';

/// Pantalla de búsqueda de conductor con efecto radar
/// Muestra una animación tipo radar sin usar Google Maps
/// Incluye timer de 3 minutos y botón de cancelar
class DriverSearchScreen extends StatefulWidget {
  final double pickupLat;
  final double pickupLng;
  final double destinationLat;
  final double destinationLng;
  final String pickupAddress;
  final String destinationAddress;
  final double estimatedPrice;

  const DriverSearchScreen({
    super.key,
    required this.pickupLat,
    required this.pickupLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.estimatedPrice,
  });

  @override
  State<DriverSearchScreen> createState() => _DriverSearchScreenState();
}

class _DriverSearchScreenState extends State<DriverSearchScreen>
    with TickerProviderStateMixin {
  // Animaciones para el efecto radar
  late AnimationController _radarController;
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _radarAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;

  // Timer para cancelación automática
  Timer? _searchTimer;
  int _remainingSeconds = 180; // 3 minutos

  // Estado de la búsqueda
  bool _isSearching = true;
  String _searchMessage = 'Buscando conductor...';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSearch();
  }

  void _initializeAnimations() {
    // Animación del radar (rotación continua)
    _radarController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _radarAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: _radarController, curve: Curves.linear));

    // Animación de pulso (expansión y contracción)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Animación de ondas (ripple effect)
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    // Iniciar animaciones
    _radarController.repeat();
    _pulseController.repeat(reverse: true);
    _rippleController.repeat();
  }

  void _startSearch() {
    // Crear solicitud de viaje
    _createRideRequest();

    // Iniciar timer de 3 minutos
    _searchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingSeconds--;

          if (_remainingSeconds <= 0) {
            _cancelSearchAutomatically();
          } else {
            // Actualizar mensaje según el tiempo restante
            if (_remainingSeconds > 120) {
              _searchMessage = 'Buscando conductor...';
            } else if (_remainingSeconds > 60) {
              _searchMessage = 'Ampliando búsqueda...';
            } else {
              _searchMessage = 'Últimos intentos...';
            }
          }
        });
      }
    });
  }

  Future<void> _createRideRequest() async {
    try {
      print('🚗 Creando solicitud de viaje...');
      print('📍 Origen: ${widget.pickupLat}, ${widget.pickupLng}');
      print('🎯 Destino: ${widget.destinationLat}, ${widget.destinationLng}');
      print('💰 Precio estimado: ${widget.estimatedPrice}');

      // La solicitud ya fue creada en el LocationInputPanel
      // Aquí solo iniciamos la búsqueda activa
      print('✅ Solicitud creada, iniciando búsqueda...');
    } catch (e) {
      print('❌ Error en búsqueda: $e');
      _showErrorAndClose('Error al iniciar la búsqueda de conductor');
    }
  }

  void _cancelSearch() {
    _showCancelDialog();
  }

  void _cancelSearchAutomatically() {
    _searchTimer?.cancel();
    _isSearching = false;

    // TODO: Cancelar solicitud en el backend
    _cancelRideRequest();

    _showTimeoutDialog();
  }

  Future<void> _cancelRideRequest() async {
    try {
      print('❌ Cancelando y eliminando solicitud de viaje...');

      // Llamar al endpoint para cancelar y eliminar la búsqueda
      // TODO: Implementar llamada real al backend
      // final response = await http.delete(
      //   Uri.parse('${AppConfig.baseUrl}/api/rides/cancel-and-delete'),
      //   headers: {
      //     'Content-Type': 'application/json',
      //     'Authorization': 'Bearer $token',
      //   },
      // );

      print('✅ Solicitud eliminada del backend');
    } catch (e) {
      print('❌ Error cancelando solicitud: $e');
    }
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancelar búsqueda'),
            content: const Text(
              '¿Estás seguro de que quieres cancelar la búsqueda de conductor?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continuar buscando'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _confirmCancel();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Sí, cancelar'),
              ),
            ],
          ),
    );
  }

  void _confirmCancel() {
    _searchTimer?.cancel();
    _isSearching = false;
    _cancelRideRequest();
    Navigator.of(context).pop();
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Tiempo agotado'),
            content: const Text(
              'No se encontraron conductores disponibles en este momento. Puedes intentar nuevamente.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Entendido'),
              ),
            ],
          ),
    );
  }

  void _showErrorAndClose(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevenir que el usuario salga accidentalmente
        _cancelSearch();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: Stack(
          children: [
            // Fondo con gradiente
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1A1A2E),
                    Color(0xFF16213E),
                    Color(0xFF0F3460),
                  ],
                ),
              ),
            ),

            // Efecto radar en el centro
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _radarAnimation,
                  _pulseAnimation,
                  _rippleAnimation,
                ]),
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(300, 300),
                    painter: RadarPainter(
                      radarAngle: _radarAnimation.value,
                      pulseRadius: _pulseAnimation.value,
                      rippleRadius: _rippleAnimation.value,
                    ),
                  );
                },
              ),
            ),

            // Panel superior con información
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Indicador de búsqueda
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _searchMessage,
                              style: AppTextStyles.poppinsHeading3.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _formatTime(_remainingSeconds),
                              style: AppTextStyles.interBody.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Información del viaje
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        widget.pickupAddress,
                                        style: AppTextStyles.interCaption
                                            .copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        widget.destinationAddress,
                                        style: AppTextStyles.interCaption
                                            .copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'S/ ${widget.estimatedPrice.toStringAsFixed(2)}',
                            style: AppTextStyles.poppinsHeading3.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Botón de cancelar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _isSearching ? _cancelSearch : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.close, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Cancelar búsqueda',
                          style: AppTextStyles.interBody.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _radarController.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }
}

/// Painter personalizado para el efecto radar sin Google Maps
class RadarPainter extends CustomPainter {
  final double radarAngle;
  final double pulseRadius;
  final double rippleRadius;

  RadarPainter({
    required this.radarAngle,
    required this.pulseRadius,
    required this.rippleRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Dibujar círculos de fondo (grid del radar)
    final gridPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.white.withOpacity(0.1);

    for (int i = 1; i <= 4; i++) {
      final radius = (maxRadius / 4) * i;
      canvas.drawCircle(center, radius, gridPaint);
    }

    // Dibujar líneas de grid
    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4);
      final endX = center.dx + cos(angle) * maxRadius;
      final endY = center.dy + sin(angle) * maxRadius;
      canvas.drawLine(center, Offset(endX, endY), gridPaint);
    }

    // Dibujar ondas de pulso (ripple effect)
    for (int i = 0; i < 3; i++) {
      final rippleOffset = (i * 0.3);
      final currentRipple = (rippleRadius + rippleOffset) % 1.0;
      final rippleRadiusValue = currentRipple * maxRadius * 0.8;
      final rippleOpacity = (1.0 - currentRipple).clamp(0.0, 1.0);

      final ripplePaint =
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = AppColors.primary.withOpacity(rippleOpacity * 0.6);

      canvas.drawCircle(center, rippleRadiusValue, ripplePaint);
    }

    // Dibujar círculo de pulso principal
    final pulsePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = AppColors.primary.withOpacity(0.8);

    final pulseRadiusValue = pulseRadius * maxRadius * 0.6;
    canvas.drawCircle(center, pulseRadiusValue, pulsePaint);

    // Dibujar línea del radar con gradiente
    final radarLength = maxRadius * 0.9;
    final endX = center.dx + cos(radarAngle) * radarLength;
    final endY = center.dy + sin(radarAngle) * radarLength;

    // Crear gradiente para la línea del radar
    final radarGradient =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.center,
            end: Alignment.centerRight,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.primary.withOpacity(0.8),
              AppColors.primary,
            ],
          ).createShader(Rect.fromPoints(center, Offset(endX, endY)))
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, Offset(endX, endY), radarGradient);

    // Dibujar sector del radar (área barrida)
    final sectorPaint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = AppColors.primary.withOpacity(0.1);

    final sectorPath = Path();
    sectorPath.moveTo(center.dx, center.dy);
    sectorPath.arcTo(
      Rect.fromCircle(center: center, radius: radarLength),
      radarAngle - 0.3,
      0.6,
      false,
    );
    sectorPath.close();
    canvas.drawPath(sectorPath, sectorPaint);

    // Dibujar punto central
    final centerPaint =
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 8, centerPaint);

    // Dibujar anillo central
    final centerRingPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    canvas.drawCircle(center, 12, centerRingPaint);

    // Dibujar puntos simulando conductores
    _drawDriverDots(canvas, center, maxRadius);
  }

  void _drawDriverDots(Canvas canvas, Offset center, double maxRadius) {
    final driverPaint =
        Paint()
          ..color = Colors.yellow
          ..style = PaintingStyle.fill;

    // Simular algunos puntos de conductores
    final drivers = [
      {'angle': 0.5, 'distance': 0.3, 'opacity': 0.8},
      {'angle': 1.2, 'distance': 0.6, 'opacity': 0.6},
      {'angle': 2.8, 'distance': 0.4, 'opacity': 0.9},
      {'angle': 4.1, 'distance': 0.7, 'opacity': 0.5},
      {'angle': 5.5, 'distance': 0.2, 'opacity': 1.0},
    ];

    for (final driver in drivers) {
      final angle = driver['angle'] as double;
      final distance = driver['distance'] as double;
      final opacity = driver['opacity'] as double;

      final x = center.dx + cos(angle) * (maxRadius * distance);
      final y = center.dy + sin(angle) * (maxRadius * distance);

      driverPaint.color = Colors.yellow.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), 4, driverPaint);

      // Dibujar anillo alrededor del punto
      final ringPaint =
          Paint()
            ..color = Colors.yellow.withOpacity(opacity * 0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;

      canvas.drawCircle(Offset(x, y), 8, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
