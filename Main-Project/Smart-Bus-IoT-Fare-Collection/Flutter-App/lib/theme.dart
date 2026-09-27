import 'package:flutter/material.dart';

/// Central place for every colour / text style used across the dashboard so
/// the whole app stays visually consistent with the reference UI
/// (dark "control room" theme, neon-green accents, monospace metrics).
class AppColors {
  static const bg = Color(0xFF0B0F14);
  static const panel = Color(0xFF121820);
  static const panelAlt = Color(0xFF161F29);
  static const border = Color(0xFF212C38);
  static const green = Color(0xFF00E58A);
  static const blue = Color(0xFF2F80ED);
  static const amber = Color(0xFFFFB020);
  static const red = Color(0xFFFF5C5C);
  static const textPrimary = Color(0xFFE6EDF3);
  static const textSecondary = Color(0xFF8B98A5);
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.bg,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.green,
    secondary: AppColors.blue,
    surface: AppColors.panel,
    error: AppColors.red,
  ),
  fontFamily: 'Roboto',
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: AppColors.textPrimary),
    bodySmall: TextStyle(color: AppColors.textSecondary),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.panelAlt,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.green),
    ),
    labelStyle: const TextStyle(color: AppColors.textSecondary),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.green,
      foregroundColor: Colors.black,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
);

/// Reusable "panel" decoration used by every card / block on the dashboard.
/// Now includes a soft shadow so cards lift off the background instead of
/// sitting flush against it.
BoxDecoration panelDecoration({Color? color}) => BoxDecoration(
      color: color ?? AppColors.panel,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.28),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    );

/// A subtle top-to-bottom gradient used behind the header and other
/// "hero" surfaces, instead of a flat single color — this is what gives
/// the control room its depth.
LinearGradient panelGradient({Color? top, Color? bottom}) => LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [top ?? AppColors.panelAlt, bottom ?? AppColors.panel],
    );

/// A soft colored glow behind an accent element (the LIVE badge, a metric
/// value, a status dot) — cheap to add, disproportionately makes things
/// feel "alive" rather than static.
List<BoxShadow> glow(Color color, {double blur = 16, double opacity = 0.45}) => [
      BoxShadow(color: color.withOpacity(opacity), blurRadius: blur, spreadRadius: 1),
    ];
