import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// Builds ThemeData for light and dark modes using Veyra design tokens.
abstract class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color background =
        isDark ? VeyraTokens.darkBackground : VeyraTokens.lightBackground;
    final Color surface =
        isDark ? VeyraTokens.darkSurface : VeyraTokens.lightSurface;
    final Color primary = isDark ? VeyraTokens.opalMint : VeyraTokens.deepEmerald;
    final Color onPrimary = isDark ? VeyraTokens.obsidian : Colors.white;
    final Color textColor =
        isDark ? VeyraTokens.darkText : VeyraTokens.lightText;
    final Color subtextColor =
        isDark ? VeyraTokens.darkSubtext : VeyraTokens.lightSubtext;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer:
          isDark ? VeyraTokens.forestSlate : const Color(0xFFD4EBE5),
      onPrimaryContainer: isDark ? VeyraTokens.opalMint : VeyraTokens.deepEmerald,
      secondary: VeyraTokens.antiqueGold,
      onSecondary: isDark ? VeyraTokens.obsidian : Colors.white,
      secondaryContainer:
          isDark ? const Color(0xFF3A2E1A) : const Color(0xFFF5ECD8),
      onSecondaryContainer:
          isDark ? VeyraTokens.premiumGold : VeyraTokens.antiqueGold,
      error: VeyraTokens.error,
      onError: Colors.white,
      errorContainer: isDark
          ? const Color(0xFF4A1B1C)
          : const Color(0xFFFFDAD6),
      onErrorContainer: isDark ? const Color(0xFFFFB4AB) : VeyraTokens.error,
      surface: surface,
      onSurface: textColor,
      onSurfaceVariant: subtextColor,
      outline: isDark ? VeyraTokens.darkBorder : VeyraTokens.lightBorder,
      outlineVariant:
          isDark ? VeyraTokens.darkDivider : VeyraTokens.lightDivider,
      shadow: Colors.black,
      scrim: Colors.black.withValues(alpha: 0.4),
      inverseSurface:
          isDark ? VeyraTokens.lightSurface : VeyraTokens.darkSurface,
      onInverseSurface:
          isDark ? VeyraTokens.lightText : VeyraTokens.darkText,
      inversePrimary:
          isDark ? VeyraTokens.deepEmerald : VeyraTokens.opalMint,
      surfaceTint: primary.withValues(alpha: 0.05),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: VeyraTokens.fontBody,
      textTheme: _buildTextTheme(textColor, subtextColor, isDark),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: VeyraTokens.headlineMedium.copyWith(
          color: textColor,
          shadows: VeyraTokens.headingShadows(isDark),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(VeyraTokens.radiusLG),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: VeyraTokens.spaceMD,
          vertical: VeyraTokens.spaceMD,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: VeyraTokens.spaceLG,
            vertical: VeyraTokens.spaceMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
          ),
          textStyle: VeyraTokens.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor:
            isDark ? VeyraTokens.darkCardSurface : VeyraTokens.lightCardSurface,
        selectedColor: primary,
        labelStyle: VeyraTokens.labelSmall.copyWith(color: textColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VeyraTokens.radiusFull),
          side: BorderSide(
            color: isDark ? VeyraTokens.darkBorder : VeyraTokens.lightBorder,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: VeyraTokens.spaceMD,
          vertical: VeyraTokens.spaceXS,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: subtextColor,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        selectedIconTheme: IconThemeData(color: primary),
        unselectedIconTheme: IconThemeData(color: subtextColor),
        indicatorColor: primary.withValues(alpha: 0.15),
        labelType: NavigationRailLabelType.all,
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? VeyraTokens.darkDivider : VeyraTokens.lightDivider,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor:
            isDark ? VeyraTokens.darkCardSurface : VeyraTokens.lightText,
        contentTextStyle: VeyraTokens.bodyMedium.copyWith(
          color: isDark ? VeyraTokens.darkText : Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VeyraTokens.radiusMD),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static TextTheme _buildTextTheme(Color text, Color subtext, bool isDark) {
    final shadows = VeyraTokens.headingShadows(isDark);
    return TextTheme(
      displayLarge: VeyraTokens.displayLarge.copyWith(color: text, shadows: shadows),
      displayMedium: VeyraTokens.displayMedium.copyWith(color: text, shadows: shadows),
      displaySmall: VeyraTokens.displaySmall.copyWith(color: text, shadows: shadows),
      headlineLarge: VeyraTokens.headlineLarge.copyWith(color: text, shadows: shadows),
      headlineMedium: VeyraTokens.headlineMedium.copyWith(color: text, shadows: shadows),
      headlineSmall: VeyraTokens.headlineMedium.copyWith(
        color: text,
        fontSize: 15,
        shadows: shadows,
      ),
      bodyLarge: VeyraTokens.bodyLarge.copyWith(color: text),
      bodyMedium: VeyraTokens.bodyMedium.copyWith(color: subtext),
      bodySmall: VeyraTokens.bodySmall.copyWith(color: subtext),
      labelLarge: VeyraTokens.labelLarge.copyWith(color: text),
      labelSmall: VeyraTokens.labelSmall.copyWith(color: subtext),
      titleLarge: VeyraTokens.headlineLarge.copyWith(color: text, shadows: shadows),
      titleMedium: VeyraTokens.headlineMedium.copyWith(color: text, shadows: shadows),
      titleSmall: VeyraTokens.bodyLarge.copyWith(
        color: text,
        fontWeight: FontWeight.w600,
        shadows: shadows,
      ),
    );
  }
}
