import 'package:flutter/material.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';

/// DriverStatusToggle
/// ------------------
/// Widget que permite al conductor cambiar su estado de disponibilidad.
/// Muestra dos chips: "Disponible" y "Ocupado" con diseño mejorado.
class DriverStatusToggle extends StatelessWidget {
  final bool isAvailable;
  final Function(bool) onStatusChanged;

  const DriverStatusToggle({
    super.key,
    required this.isAvailable,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón "Disponible"
          Expanded(
            child: GestureDetector(
              onTap: () => onStatusChanged(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isAvailable ? Colors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow:
                      isAvailable
                          ? [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: isAvailable ? Colors.white : Colors.grey[600],
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Disponible',
                      style: AppTextStyles.interBody.copyWith(
                        color: isAvailable ? Colors.white : Colors.grey[600],
                        fontWeight:
                            isAvailable ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Botón "Ocupado"
          Expanded(
            child: GestureDetector(
              onTap: () => onStatusChanged(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isAvailable ? Colors.red : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow:
                      !isAvailable
                          ? [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cancel,
                      color: !isAvailable ? Colors.white : Colors.grey[600],
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ocupado',
                      style: AppTextStyles.interBody.copyWith(
                        color: !isAvailable ? Colors.white : Colors.grey[600],
                        fontWeight:
                            !isAvailable ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
