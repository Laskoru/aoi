import 'package:flutter/material.dart';
import 'app_palette.dart';

/// Couleurs qui n'ont pas d'équivalent dans un [ColorScheme] Material : les
/// trois états de l'eau, et le fond assorti pour les afficher en pastille.
@immutable
class PondColors extends ThemeExtension<PondColors> {
  final Color ideal;
  final Color warning;
  final Color danger;
  final Color idealSurface;
  final Color warningSurface;
  final Color dangerSurface;

  const PondColors({
    required this.ideal,
    required this.warning,
    required this.danger,
    required this.idealSurface,
    required this.warningSurface,
    required this.dangerSurface,
  });

  static const light = PondColors(
    ideal: AppPalette.idealLight,
    warning: AppPalette.warningLight,
    danger: AppPalette.dangerLight,
    idealSurface: Color(0xFFE8F3ED),
    warningSurface: Color(0xFFFBF0E0),
    dangerSurface: Color(0xFFFAE8E6),
  );

  static const dark = PondColors(
    ideal: AppPalette.idealDark,
    warning: AppPalette.warningDark,
    danger: AppPalette.dangerDark,
    idealSurface: Color(0xFF17302A),
    warningSurface: Color(0xFF322715),
    dangerSurface: Color(0xFF3A1F1D),
  );

  @override
  PondColors copyWith({
    Color? ideal,
    Color? warning,
    Color? danger,
    Color? idealSurface,
    Color? warningSurface,
    Color? dangerSurface,
  }) {
    return PondColors(
      ideal: ideal ?? this.ideal,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      idealSurface: idealSurface ?? this.idealSurface,
      warningSurface: warningSurface ?? this.warningSurface,
      dangerSurface: dangerSurface ?? this.dangerSurface,
    );
  }

  @override
  PondColors lerp(ThemeExtension<PondColors>? other, double t) {
    if (other is! PondColors) return this;
    return PondColors(
      ideal: Color.lerp(ideal, other.ideal, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      idealSurface: Color.lerp(idealSurface, other.idealSurface, t)!,
      warningSurface: Color.lerp(warningSurface, other.warningSurface, t)!,
      dangerSurface: Color.lerp(dangerSurface, other.dangerSurface, t)!,
    );
  }
}

/// Raccourcis de lecture du thème, pour que les écrans écrivent
/// `context.colors.primary` plutôt que `Theme.of(context).colorScheme.primary`.
extension AppThemeAccess on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get texts => Theme.of(this).textTheme;
  PondColors get pond => Theme.of(this).extension<PondColors>() ?? PondColors.light;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(_lightScheme, PondColors.light);
  static ThemeData dark() => _build(_darkScheme, PondColors.dark);

  // --- Schémas de couleurs ---

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppPalette.mizuDeep,
    onPrimary: AppPalette.shirojiPure,
    primaryContainer: AppPalette.mizuWash,
    onPrimaryContainer: AppPalette.mizuDeep,
    secondary: AppPalette.hi,
    onSecondary: AppPalette.shirojiPure,
    secondaryContainer: AppPalette.hiWash,
    onSecondaryContainer: AppPalette.hiDeep,
    tertiary: AppPalette.mizuMid,
    onTertiary: AppPalette.shirojiPure,
    error: AppPalette.dangerLight,
    onError: AppPalette.shirojiPure,
    surface: AppPalette.shirojiPure,
    onSurface: AppPalette.sumi,
    onSurfaceVariant: AppPalette.sumiMuted,
    surfaceContainerLowest: AppPalette.shirojiPure,
    surfaceContainerLow: AppPalette.shiroji,
    surfaceContainer: AppPalette.shiroji,
    surfaceContainerHigh: AppPalette.shirojiShade,
    surfaceContainerHighest: AppPalette.shirojiShade,
    outline: AppPalette.shirojiLine,
    outlineVariant: AppPalette.shirojiShade,
    shadow: AppPalette.sumi,
    inverseSurface: AppPalette.sumi,
    onInverseSurface: AppPalette.shiroji,
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    // Sur fond sombre, le bleu profond disparaîtrait : on remonte vers les
    // tons d'eau éclairée pour garder du contraste.
    primary: AppPalette.mizuLight,
    onPrimary: AppPalette.nightBase,
    primaryContainer: Color(0xFF1B3B4A),
    onPrimaryContainer: AppPalette.mizuLight,
    secondary: AppPalette.hiBright,
    onSecondary: AppPalette.nightBase,
    secondaryContainer: Color(0xFF3B2018),
    onSecondaryContainer: AppPalette.hiBright,
    tertiary: Color(0xFF7FC0DA),
    onTertiary: AppPalette.nightBase,
    error: AppPalette.dangerDark,
    onError: AppPalette.nightBase,
    surface: AppPalette.nightSurface,
    onSurface: AppPalette.nightText,
    onSurfaceVariant: AppPalette.nightTextMuted,
    surfaceContainerLowest: AppPalette.nightBase,
    surfaceContainerLow: AppPalette.nightBase,
    surfaceContainer: AppPalette.nightSurface,
    surfaceContainerHigh: AppPalette.nightRaised,
    surfaceContainerHighest: AppPalette.nightRaised,
    outline: AppPalette.nightLine,
    outlineVariant: AppPalette.nightLine,
    shadow: Color(0xFF000000),
    inverseSurface: AppPalette.shiroji,
    onInverseSurface: AppPalette.sumi,
  );

  // --- Assemblage ---

  static ThemeData _build(ColorScheme scheme, PondColors pond) {
    final isDark = scheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark
          ? AppPalette.nightBase
          : AppPalette.shiroji,
      textTheme: _textTheme(scheme),
      extensions: [pond],
      splashFactory: InkSparkle.splashFactory,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        prefixIconColor: scheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.outline,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.field),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: scheme.primary),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
      ),
      dividerColor: scheme.outlineVariant,
    );
  }

  /// Échelle typographique : titres serrés et contrastés, corps de texte
  /// aéré, libellés discrets pour les métadonnées.
  static TextTheme _textTheme(ColorScheme scheme) {
    return TextTheme(
      displaySmall: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.8,
        color: scheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        color: scheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.3,
        color: scheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      bodyLarge: TextStyle(fontSize: 15, height: 1.5, color: scheme.onSurface),
      bodyMedium: TextStyle(
        fontSize: 13.5,
        height: 1.45,
        color: scheme.onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
        color: scheme.onSurfaceVariant,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.8,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}
