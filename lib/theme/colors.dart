import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color accent = Color(0xFF06D6A0);
  static const Color warning = Color(0xFFFFD166);
  static const Color danger = Color(0xFFEF476F);
  
  static const Color background = Color(0xFFF8FAFC);
  static const Color darkBackground = Color(0xFF0F172A);
  
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  
  // Safety colors
  static const Color safe = Color(0xFF06D6A0);
  static const Color moderate = Color(0xFFFFD166);
  static const Color unsafe = Color(0xFFEF476F);
  static const Color unknown = Color(0xFF94A3B8);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient safetyGradient = LinearGradient(
    colors: [safe, moderate, unsafe],
    stops: [0.0, 0.5, 1.0],
  );
}