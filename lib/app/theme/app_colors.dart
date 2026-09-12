import 'package:flutter/material.dart';

class AppColors {
  // Main Violet Brand Palette (Specified Requirements)
  static const Color primaryViolet = Color(0xFF6C4AB6);
  static const Color darkViolet = Color(0xFF452B78);
  static const Color lightViolet = Color(0xFFEDE7F6);
  static const Color softViolet = Color(0xFFF5F1FB);
  static const Color accentPurple = Color(0xFF8E6BC8);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF7F7F9);
  static const Color darkText = Color(0xFF252331);
  static const Color secondaryText = Color(0xFF6B6875);

  // Backward Compatibility & System Mappings
  static const Color primary = primaryViolet;
  static const Color primaryVariant = darkViolet;
  static const Color secondary = accentPurple;
  static const Color darkBackground = darkViolet;
  static const Color surfaceDark = Color(0xFF2E1C54);
  
  // Status Colors (Balanced with Violet Theme)
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Neutral Palette
  static const Color background = lightGray;
  static const Color surface = white;
  static const Color textPrimary = darkText;
  static const Color textSecondary = secondaryText;
  static const Color textMuted = Color(0xFFA09DAA);
  static const Color border = Color(0xFFE5E0EE);
  static const Color inputBackground = softViolet;

  // AI & Risk Highlights
  static const Color riskLow = Color(0xFF10B981);
  static const Color riskMedium = Color(0xFFF59E0B);
  static const Color riskHigh = Color(0xFFEF4444);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [darkViolet, primaryViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [darkViolet, primaryViolet, accentPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient aiBadgeGradient = LinearGradient(
    colors: [primaryViolet, accentPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

