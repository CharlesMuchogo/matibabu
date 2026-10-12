import 'package:flutter/material.dart';

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  static const EdgeInsets page = EdgeInsets.all(md);
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets card = EdgeInsets.all(md);

  static const double radius = 16;
  static const double radiusSm = 12;
}

class AppColors {
  static const Color seed = Color(0xFF008080);
  static const Color pending = Color(0xFFF59E0B);
  static const Color confirmed = Color(0xFF16A34A);
  static const Color cancelled = Color(0xFFDC2626);
  static const Color completed = Color(0xFF2563EB);
}

class GitHubDark {
  static const Color canvas = Color(0xFF0D1117);
  static const Color inset = Color(0xFF010409);
  static const Color subtle = Color(0xFF161B22);
  static const Color muted = Color(0xFF21262D);
  static const Color border = Color(0xFF30363D);
  static const Color subtleBorder = Color(0xFF6E7681);
  static const Color text = Color(0xFFE6EDF3);
  static const Color mutedText = Color(0xFF8B949E);

  static ColorScheme apply(ColorScheme scheme) => scheme.copyWith(
    surface: canvas,
    onSurface: text,
    onSurfaceVariant: mutedText,
    surfaceDim: canvas,
    surfaceBright: muted,
    surfaceContainerLowest: inset,
    surfaceContainerLow: subtle,
    surfaceContainer: subtle,
    surfaceContainerHigh: muted,
    surfaceContainerHighest: border,
    outline: subtleBorder,
    outlineVariant: border,
  );
}

class AppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = isDark
        ? GitHubDark.apply(
            ColorScheme.fromSeed(
              seedColor: AppColors.seed,
              brightness: Brightness.dark,
            ),
          )
        : ColorScheme.fromSeed(
            seedColor: AppColors.seed,
            primary: AppColors.seed,
            surface: const Color(0xFFF7FAFA),
          );
    final cardColor = isDark ? scheme.surfaceContainer : Colors.white;
    final fieldColor = isDark ? scheme.surfaceContainerHigh : Colors.white;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      borderSide: BorderSide(color: scheme.outlineVariant),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        indicatorColor: scheme.primaryContainer,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
