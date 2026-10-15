import 'package:flutter/material.dart';

/// Veyra Design Tokens — single source of truth for all visual constants.
abstract class VeyraTokens {
  // ── Palette ──────────────────────────────────────────────────────────────
  static const Color pearlIvory = Color(0xFFF7F4EC);
  static const Color deepEmerald = Color(0xFF235B50);
  static const Color antiqueGold = Color(0xFFCBA66A);
  static const Color obsidian = Color(0xFF101918);
  static const Color forestSlate = Color(0xFF1D2B28);
  static const Color opalMint = Color(0xFF86D0B7);
  static const Color premiumGold = Color(0xFFD8B779);

  // Light surface
  static const Color lightBackground = Color(0xFFF7F4EC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardSurface = Color(0xFFFAF8F3);
  static const Color lightText = Color(0xFF202A27);
  static const Color lightSubtext = Color(0xFF5C6B66);
  static const Color lightBorder = Color(0xFFE5E0D5);
  static const Color lightDivider = Color(0xFFEDE9E0);

  // Dark surface
  static const Color darkBackground = Color(0xFF101918);
  static const Color darkSurface = Color(0xFF1D2B28);
  static const Color darkCardSurface = Color(0xFF253330);
  static const Color darkText = Color(0xFFF2F4EF);
  static const Color darkSubtext = Color(0xFF9BAFA9);
  static const Color darkBorder = Color(0xFF2E403C);
  static const Color darkDivider = Color(0xFF243330);

  // Semantic colors
  static const Color success = Color(0xFF2E7D5E);
  static const Color error = Color(0xFFB5373A);
  static const Color warning = Color(0xFFCB8B3A);
  static const Color info = Color(0xFF2B6CB0);

  // ── Typography ───────────────────────────────────────────────────────────
  static const String fontDisplay = 'Playfair';
  static const String fontBody = 'Inter';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.25,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontBody,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
    height: 1.35,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontBody,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontBody,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontBody,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontBody,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontBody,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontBody,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontBody,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontBody,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontBody,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // ── Spacing ──────────────────────────────────────────────────────────────
  static const double spaceXS = 4;
  static const double spaceSM = 8;
  static const double spaceMD = 16;
  static const double spaceLG = 24;
  static const double spaceXL = 32;
  static const double space2XL = 48;
  static const double space3XL = 64;

  // ── Radii ────────────────────────────────────────────────────────────────
  static const double radiusXS = 6;
  static const double radiusSM = 10;
  static const double radiusMD = 16;
  static const double radiusLG = 20;
  static const double radiusXL = 24;
  static const double radiusFull = 100;

  // ── Elevation / Shadows ──────────────────────────────────────────────────
  static List<BoxShadow> get shadowSM => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMD => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get shadowLG => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowEmerald(bool dark) => [
    BoxShadow(
      color: deepEmerald.withValues(alpha: dark ? 0.4 : 0.25),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  // ── Text Shadows for Headings ─────────────────────────────────────────────
  static List<Shadow> headingShadows(bool isDark) => [
    Shadow(
      color: isDark ? const Color(0x77000000) : const Color(0x261B3B36),
      offset: const Offset(0, 1.5),
      blurRadius: 3.5,
    ),
    Shadow(
      color: isDark
          ? opalMint.withValues(alpha: 0.18)
          : antiqueGold.withValues(alpha: 0.22),
      offset: const Offset(0, 3.0),
      blurRadius: 8.0,
    ),
  ];

  // ── Durations ────────────────────────────────────────────────────────────
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 280);
  static const Duration durationSlow = Duration(milliseconds: 450);

  static const Curve curveDefault = Curves.easeInOutCubic;
  static const Curve curveEmphasized = Curves.easeOutBack;

  // ── Breakpoints ──────────────────────────────────────────────────────────
  static const double compactBreakpoint = 600;
  static const double mediumBreakpoint = 900;
}
