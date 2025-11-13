import 'package:flutter/material.dart';

// Central application theme definitions.
class AppTheme {
  AppTheme._();

  // Fully defined dark color scheme using requested palette accents.
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF1976D2), // blue
    onPrimary: Colors.white,
    secondary: Color(0xFF2E7D32), // green
    onSecondary: Colors.white,
    tertiary: Color(0xFF455A64), // blue-grey accent
    onTertiary: Colors.white,
    error: Color(0xFFD32F2F), // red
    onError: Colors.white,
    background: Color(0xFF121212), // near-black
    onBackground: Colors.white,
    surface: Color(0xFF1E1E24), // dark surface
    onSurface: Colors.white,
    surfaceVariant: Color(0xFF2C2F33),
    onSurfaceVariant: Color(0xFFB0BEC5),
    outline: Color(0xFF4F5B62),
    outlineVariant: Color(0xFF37474F),
    inverseSurface: Colors.white,
    onInverseSurface: Color(0xFF121212),
    inversePrimary: Color(0xFF90CAF9),
    shadow: Colors.black,
    scrim: Colors.black,
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
    scaffoldBackgroundColor: darkColorScheme.background,
    canvasColor: darkColorScheme.background,
    textTheme: _textTheme(),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return darkColorScheme.primary.withOpacity(0.25);
          }
          return darkColorScheme.primary;
        }),
        foregroundColor: WidgetStateProperty.all(darkColorScheme.onPrimary),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        elevation: WidgetStateProperty.all(2),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkColorScheme.secondary,
      foregroundColor: darkColorScheme.onSecondary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF23262B),
      labelStyle: TextStyle(color: darkColorScheme.onSurface.withOpacity(.85)),
      hintStyle: TextStyle(color: darkColorScheme.onSurfaceVariant),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: darkColorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: darkColorScheme.primary, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: darkColorScheme.outline),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: darkColorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: darkColorScheme.error, width: 2),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF2E3138),
      selectedColor: darkColorScheme.primary.withOpacity(.25),
      pressElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      labelStyle: TextStyle(color: darkColorScheme.onSurface, fontSize: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      side: BorderSide(color: darkColorScheme.outlineVariant, width: 1),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: darkColorScheme.primary,
      unselectedLabelColor: darkColorScheme.onSurfaceVariant,
      indicatorColor: darkColorScheme.primary,
      dividerColor: darkColorScheme.outlineVariant,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF202329),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.all(8),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF28313A),
      contentTextStyle: TextStyle(color: darkColorScheme.onSurface),
      actionTextColor: darkColorScheme.primary,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: darkColorScheme.primary,
      linearTrackColor: darkColorScheme.surfaceVariant,
      circularTrackColor: darkColorScheme.surfaceVariant,
    ),
    dividerColor: darkColorScheme.outlineVariant,
    iconTheme: IconThemeData(color: darkColorScheme.onSurface),
    appBarTheme: AppBarTheme(
      backgroundColor: darkColorScheme.surface,
      elevation: 1,
      centerTitle: true,
      titleTextStyle: _textTheme().titleLarge?.copyWith(
        color: darkColorScheme.onSurface,
      ),
      iconTheme: IconThemeData(color: darkColorScheme.onSurface),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF20252B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      titleTextStyle: _textTheme().titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: _textTheme().bodyMedium,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return darkColorScheme.primary;
        }
        return darkColorScheme.surfaceVariant;
      }),
      checkColor: WidgetStateProperty.all(darkColorScheme.onPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return darkColorScheme.primary;
        }
        return darkColorScheme.outlineVariant;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return darkColorScheme.primary.withOpacity(.4);
        }
        return darkColorScheme.outline.withOpacity(.3);
      }),
    ),
  );

  static TextTheme _textTheme() {
    const base =
        Typography.whiteMountainView; // good starting point for dark mode
    return base.copyWith(
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.4),
      labelLarge: base.labelLarge?.copyWith(letterSpacing: .8),
    );
  }
}
