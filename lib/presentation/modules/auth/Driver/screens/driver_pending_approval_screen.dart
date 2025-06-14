import 'package:flutter/material.dart';
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';
import 'package:joya_express/presentation/modules/routes/app_routes.dart';

class DriverPendingApprovalScreen extends StatelessWidget {
  const DriverPendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Espaciador superior reducido
              SizedBox(height: 20),
              
              // Icono principal más pequeño
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                 child: ClipOval(
                  child: Image.asset(
                    'assets/images/campana.png', 
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Título principal
              Text(
                'Solicitud en Proceso',
                style: AppTextStyles.poppinsHeading1.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 24),
              
              // Contenedor con información
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Nuestro equipo está verificando tus documentos y datos. Este proceso puede tomar entre 24 a 48 horas hábiles.',
                      style: AppTextStyles.interBody.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Lista de pasos del proceso
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Qué sigue?',
                      style: AppTextStyles.poppinsHeading3.copyWith(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildProcessStep(
                      icon: Icons.check_circle,
                      title: 'Documentos recibidos',
                      description: 'Hemos recibido tu información',
                      isCompleted: true,
                    ),
                    SizedBox(height: 8),
                    _buildProcessStep(
                      icon: Icons.access_time,
                      title: 'Verificación en proceso',
                      description: 'Revisando tus documentos',
                      isCompleted: false,
                      isActive: true,
                    ),
                    SizedBox(height: 8),
                    _buildProcessStep(
                      icon: Icons.notifications_active,
                      title: 'Notificación de resultado',
                      description: 'Te contactaremos pronto',
                      isCompleted: false,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 32),
              
              // Botón de iniciar sesión
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.driverLogin,
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Iniciar Sesión',
                    style: AppTextStyles.poppinsButton,
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Texto de contacto
              Text(
                '¿Tienes preguntas? Contáctanos al soporte',
                style: AppTextStyles.interBodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessStep({
    required IconData icon,
    required String title,
    required String description,
    required bool isCompleted,
    bool isActive = false,
  }) {
    Color iconColor;
    Color titleColor;
    Color descriptionColor;
    
    if (isCompleted) {
      iconColor = AppColors.success;
      titleColor = AppColors.success;
      descriptionColor = AppColors.textSecondary;
    } else if (isActive) {
      iconColor = AppColors.warning;
      titleColor = AppColors.textPrimary;
      descriptionColor = AppColors.textSecondary;
    } else {
      iconColor = AppColors.textSecondary;
      titleColor = AppColors.textSecondary;
      descriptionColor = AppColors.textSecondary;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.interBody.copyWith(
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              SizedBox(height: 2),
              Text(
                description,
                style: AppTextStyles.interCaption.copyWith(
                  color: descriptionColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}