import 'package:flutter/material.dart';

class AppColors {
  // --- Core Luxury Emerald Palette ---
  static const Color primary = Color(0xFF059669); // Emerald 600
  static const Color primaryDark = Color(0xFF047857); // Emerald 700
  static const Color primaryDeep = Color(0xFF064E3B); // Emerald 800
  static const Color primaryMidnight = Color(0xFF022C22); // Emerald 950
  static const Color primaryLight = Color(0xFF10B981); // Emerald 500
  static const Color primarySoft = Color(0xFF34D399); // Emerald 400 / Mint
  static const Color primarySurface = Color(0xFFECFDF5); // Emerald 50
  static const Color primaryBorder = Color(0xFFA7F3D0); // Emerald 200

  // --- Accents & Complementary ---
  static const Color accent = Color(0xFF34D399); // Vibrant Mint
  static const Color accentSoft = Color(0xFF6EE7B7); // Mint 300
  static const Color accentGlow = Color(0xFF059669);
  static const Color secondary = Color(0xFF0D9488); // Teal 600

  // --- Semantic Status Colors ---
  static const Color success = Color(0xFF10B981); // Hadir / On-time
  static const Color successSoft = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B); // Izin / Telat
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF0284C7); // Pulang / Lengkap
  static const Color infoSoft = Color(0xFFE0F2FE);
  static const Color error = Color(0xFFEF4444); // Ditolak / Mock GPS
  static const Color errorSoft = Color(0xFFFEE2E2);

  // --- Light Mode (Clean & Airy with Emerald Wash) ---
  static const Color lightBg = Color(0xFFF4F8F6); // Soft emerald mist
  static const Color lightSurface = Colors.white;
  static const Color lightCard = Colors.white;
  static const Color lightCardElevated = Colors.white;
  static const Color lightTextPrimary = Color(0xFF0B1E19); // Rich forest charcoal
  static const Color lightTextSecondary = Color(0xFF475E57); // High contrast sage
  static const Color lightBorder = Color(0xFFE0EBE6); // Clean subtle border

  // --- Dark Mode (Deep Emerald Forest Midnight - Luxury Feel) ---
  static const Color darkBg = Color(0xFF060E0C); // Ultra deep forest black
  static const Color darkSurface = Color(0xFF0D1C18); // Forest card container
  static const Color darkCard = Color(0xFF122420); // Elevated forest card
  static const Color darkCardElevated = Color(0xFF1A332E); // High elevation surface
  static const Color darkTextPrimary = Color(0xFFF0FDF8); // Crisp mint-white
  static const Color darkTextSecondary = Color(0xFF89A59D); // Legible muted sage
  static const Color darkBorder = Color(0xFF1F3831); // Glowing forest border

  // --- Premium Gradients ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGlowGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF022C22), Color(0xFF064E3B), Color(0xFF047857)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradientSubtle = LinearGradient(
    colors: [Color(0xFF064E3B), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF162B26), Color(0xFF0F1E1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightCardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF9FCFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
