import 'dart:ui';
import 'package:flutter/material.dart';

// Clase para manejar colores dinámicos según el tema
class AppColors {
  // Colores base que no cambian
  static const Color primaryBlue = Color(0xFF1EADF0);
  static const Color primaryGreen = Color(0xFF0AFB60);

  // Colores para tema oscuro (actual)
  static const Color darkBackground = Colors.black;
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkInputFill = Color(0x58696969);
  static const Color darkIcon = Color(0xFFBDBDBD);
  static const Color darkBorder = Color.fromARGB(255, 126, 126, 126);
  static const Color darkTextPrimary = Color.fromARGB(255, 255, 255, 255);
  static const Color darkTextSecondary = Color.fromARGB(218, 130, 130, 130);
  static const Color darkPrimaryGradient = Color.fromARGB(109, 30, 173, 240);
  static const Color darkSecondaryGradient = Color.fromARGB(96, 10, 251, 94);

  // Colores para tema claro
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightInputFill = Color(0x20000000);
  static const Color lightIcon = Color(0xFF757575);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightPrimaryGradient = Color.fromARGB(50, 30, 173, 240);
  static const Color lightSecondaryGradient = Color.fromARGB(50, 10, 251, 94);

  // Métodos para obtener colores según el contexto
  static Color getPrimaryColor(BuildContext context) {
    return primaryBlue;
  }

  static Color getSecondaryColor(BuildContext context) {
    return primaryGreen;
  }

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : lightBackground;
  }

  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : lightSurface;
  }

  static Color getInputFillColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkInputFill
        : lightInputFill;
  }

  static Color getIconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkIcon
        : lightIcon;
  }

  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorder
        : lightBorder;
  }

  static Color getTextPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : lightTextPrimary;
  }

  static Color getTextSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : lightTextSecondary;
  }

  static Color getPrimaryGradientColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkPrimaryGradient
        : lightPrimaryGradient;
  }

  static Color getSecondaryGradientColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSecondaryGradient
        : lightSecondaryGradient;
  }
}

// Variables globales para compatibilidad con código existente (deprecated)
@deprecated
final Color primaryColor = AppColors.primaryBlue;
@deprecated
final Color secondaryColor = AppColors.primaryGreen;
@deprecated
final Color primaryGradientColor = AppColors.darkPrimaryGradient;
@deprecated
final Color secondaryGradientColor = AppColors.darkSecondaryGradient;
@deprecated
final Color inputFillColor = AppColors.darkInputFill;
@deprecated
final Color iconColor = AppColors.darkIcon;
@deprecated
final Color borderColor = AppColors.darkBorder;
@deprecated
final Color textPrimaryColor = AppColors.darkTextPrimary;
@deprecated
final Color textSecondaryColor = AppColors.darkTextSecondary;
