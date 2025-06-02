import 'package:flutter/material.dart';
// Importamos colores y estilos personalizados
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';

/***
  Version personalizada de ElevatedButton con estilos definidos 
***/
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;  
  final double height;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    // El botón solo se puede presionar si está habilitado, no está cargando y tiene función asignada    
    final bool canPress = isEnabled && !isLoading && onPressed != null;
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
         // Si no se puede presionar, el botón queda deshabilitado
        onPressed: canPress ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canPress 
              ? (backgroundColor ?? AppColors.primary)// Color de fondo activo
              : AppColors.buttonDisabled,// Color de fondo desactivado
          foregroundColor: canPress
              ? (textColor ?? AppColors.white) // Color del texto activo
              : AppColors.buttonTextDisabled, // Color del texto desactivado
          elevation: 0,// Sin sombra elevada
          shadowColor: Colors.transparent,// Sin sombra proyectada
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
         // Si está cargando, muestra un indicador circular
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
              // Si no, muestra el texto con el estilo correspondiente
            : Text(
                text,
                style: canPress 
                    ? AppTextStyles.poppinsButton.copyWith(color: textColor ?? AppColors.white)
                    : AppTextStyles.poppinsButtonDisabled,
              ),
      ),
    );
  }
}
// Widget de botón delineado personalizado (sin fondo sólido)
class CustomOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final Color? borderColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;

  const CustomOutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isEnabled = true,
    this.borderColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    // El botón solo se puede presionar si está habilitado y tiene función asignada
    final bool canPress = isEnabled && onPressed != null;
    
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        // Si no se puede presionar, el botón queda deshabilitado
        onPressed: canPress ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: canPress 
              ? (textColor ?? AppColors.primary)// Color del texto activo
              : AppColors.textDisabled,// Color del texto deshabilitado
          side: BorderSide(
            color: canPress 
                ? (borderColor ?? AppColors.primary)// Borde activo
                : AppColors.border,// Borde deshabilitado
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Text(
          text,
          style: AppTextStyles.poppinsButton.copyWith(
            color: canPress 
                ? (textColor ?? AppColors.primary)
                : AppColors.textDisabled,
          ),
        ),
      ),
    );
  }
}