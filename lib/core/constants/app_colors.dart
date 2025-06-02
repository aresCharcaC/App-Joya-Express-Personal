import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFFE53E3E); // Rojo principal
  static const Color primaryLight = Color(0xFFFF6B6B);
  static const Color primaryDark = Color(0xFFB91C1C);

  // Secondary Colors
  static const Color secondary = Color(0xFF68D391); // Verde de éxito
  static const Color secondaryLight = Color(0xFF9AE6B4);
  static const Color secondaryDark = Color(0xFF38A169);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF6B7280);
  static const Color greyLight = Color(0xFFF3F4F6);
  static const Color greyDark = Color(0xFF374151);

  // Background Colors
  static const Color background = Color(0xFFFAFAFA); //Fondo
  static const Color surface = Color(0xFFFFFFFF); //Superficie

  // Border Colors (colores para bordes y contornos)
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderActive = Color(0xFF68D391);
  static const Color borderError = Color(0xFFEF4444);

  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF9CA3AF);

  // Button Colors (para botones y textos de botones)
  static const Color buttonDisabled = Color(0xFFD1D5DB);
  static const Color buttonTextDisabled = Color(0xFF9CA3AF);

  // Status Colors (para estados de éxito, advertencia, error e información)
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}