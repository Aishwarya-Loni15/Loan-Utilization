import 'package:flutter/material.dart';

class AppColors {
  // Brand Core
  static const Color primary = Color(0xFF2015FF);
  static const Color primaryVariant = Color(0xFF110ABF);
  static const Color secondary = Color(0xFF00E676);
  static const Color darkBackground = Color(0xFF0D0F1D);
  static const Color surfaceDark = Color(0xFF16192E);
  
  // Status Colors
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFAB00);
  static const Color danger = Color(0xFFFF3D00);
  static const Color info = Color(0xFF29B6F6);

  // Neutral Palette
  static const Color background = Color(0xFFF7F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0A0E2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color inputBackground = Color(0xFFF3F4F6);

  // AI & Risk Gradients / Highlights
  static const Color riskLow = Color(0xFF10B981);
  static const Color riskMedium = Color(0xFFF59E0B);
  static const Color riskHigh = Color(0xFFEF4444);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2015FF), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient aiBadgeGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF2015FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
