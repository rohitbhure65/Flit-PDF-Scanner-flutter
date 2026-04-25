import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary - Sophisticated Indigo
  static const Color primary = Color(0xFFE53935);
  static const Color primaryLight = Color(0xFFFF6F60); // Light red
  static const Color primaryDark = Color(0xFFB71C1C); // Dark red

  static const Color secondary = Color(0xFFFF8A65); // Soft orange-red
  static const Color secondaryLight = Color(0xFFFFAB91);
  static const Color secondaryDark = Color(0xFFD84315);

  // Neutral Colors - Light Mode
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color card = Colors.white;

  // Neutral Colors - Dark Mode
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);

  // Text Colors - Light Mode
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Colors.white;

  // Text Colors - Dark Mode
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color dividerDark = Color(0xFF334155);

  // Special
  static const Color shadow = Color(0x0D000000); // Very soft shadow
  static const Color shadowDark = Color(0x33000000);
  static const Color glassEffect = Color(0x1AFFFFFF);

  // Grey Scale
  static const Color grey50 = Color(0xFFF8FAFC);
  static const Color grey100 = Color(0xFFF1F5F9);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey300 = Color(0xFFCBD5E1);
  static const Color grey400 = Color(0xFF94A3B8);
  static const Color grey500 = Color(0xFF64748B);
}
