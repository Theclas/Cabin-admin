import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF0F0F1A);
  static const Color sidebar = Color(0xFF1A1A2E);
  static const Color card = Color(0xFF1E1E32);
  static const Color hover = Color(0xFF252540);
  static const Color border = Color(0xFF2A2A40);

  // Brand
  static const Color primary = Color(0xFF8B2FBF);
  static const Color secondary = Color(0xFFE91E63);
  static const Color accent = Color(0xFFFF6B35);
  static const Color detail = Color(0xFFFFD93D);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8B8C8);
  static const Color textHint = Color(0xFF6B6B8A);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sidebarGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16162A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: border, width: 1),
  );

  static BoxDecoration get cardHoverDecoration => BoxDecoration(
    color: hover,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: primary.withValues(alpha: 0.4), width: 1),
  );
}
