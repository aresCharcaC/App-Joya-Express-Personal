import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

// Clase para centralizar estilos de texto usados en la app
class AppTextStyles {
  AppTextStyles._(); // Constructor privado para evitar instanciación

  // Estilos con fuente Poppins (títulos y botones)
  static TextStyle get poppinsHeading1 => GoogleFonts.poppins(
        fontSize: 32, // Título principal
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get poppinsHeading2 => GoogleFonts.poppins(
        fontSize: 24, // Título secundario
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get poppinsHeading3 => GoogleFonts.poppins(
        fontSize: 20, // Título terciario
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get poppinsButton => GoogleFonts.poppins(
        fontSize: 16, // Texto de botón activo
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      );

  static TextStyle get poppinsButtonDisabled => GoogleFonts.poppins(
        fontSize: 16, // Texto de botón deshabilitado
        fontWeight: FontWeight.w600,
        color: AppColors.buttonTextDisabled,
      );

  static TextStyle get poppinsSubtitle => GoogleFonts.poppins(
        fontSize: 16, // Subtítulos
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  // Estilos con fuente Inter (cuerpo y formularios)
  static TextStyle get interBody => GoogleFonts.inter(
        fontSize: 16, // Texto principal
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      );

  static TextStyle get interBodySmall => GoogleFonts.inter(
        fontSize: 14, // Texto secundario
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      );

  static TextStyle get interCaption => GoogleFonts.inter(
        fontSize: 12, // Texto de ayuda o pie
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      );

  static TextStyle get interInput => GoogleFonts.inter(
        fontSize: 16, // Texto de campos de entrada
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      );

  static TextStyle get interInputHint => GoogleFonts.inter(
        fontSize: 16, // Placeholder en campos de entrada
        fontWeight: FontWeight.normal,
        color: AppColors.textDisabled,
      );

  static TextStyle get interLink => GoogleFonts.inter(
        fontSize: 14, // Texto de enlaces
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
        decoration: TextDecoration.underline,
      );

  static TextStyle get interSuccess => GoogleFonts.inter(
        fontSize: 14, // Mensajes de éxito
        fontWeight: FontWeight.w500,
        color: AppColors.success,
      );

  static TextStyle get interError => GoogleFonts.inter(
        fontSize: 14, // Mensajes de error
        fontWeight: FontWeight.w500,
        color: AppColors.error,
      );
}