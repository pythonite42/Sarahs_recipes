import 'package:flutter/material.dart';

class GlobalThemData {
  static ThemeData lightThemeData =
      themeData(lightColorScheme, Color(0xFF8C1A6A));

  static ThemeData darkThemeData =
      themeData(darkColorScheme, Color(0xFF8C1A6A));

  static ThemeData themeData(ColorScheme colorScheme, Color focusColor) {
    return ThemeData(
        colorScheme: colorScheme,
        canvasColor: colorScheme.surface,
        scaffoldBackgroundColor: colorScheme.surface,
        highlightColor: Colors.transparent,
        focusColor: focusColor);
  }

  static ColorScheme lightColorScheme = ColorScheme(
    primary: Color(0xFFEFC7E5),
    onPrimary: Color(0xFF111D13),
    secondary: Color(0xFF8C1A6A),
    onSecondary: Color(0xFFFAFAFA),
    error: Color(0xFFB90E0A),
    onError: Color(0xFFFAFAFA),
    surface: Color(0xFFFAFAFA),
    surfaceDim: Color(0xFFFAEDF7),
    onSurface: Color(0xFF111D13),
    brightness: Brightness.light,
  );

  static ColorScheme darkColorScheme = ColorScheme(
    primary: Color(0xFFEFC7E5),
    onPrimary: Color(0xFF111D13),
    secondary: Color(0xFF8C1A6A),
    onSecondary: Color(0xFFFAFAFA),
    error: Color(0xFFB90E0A),
    onError: Color(0xFFFAFAFA),
    surface: Color(0xFF111D13),
    surfaceDim: Color(0xFFFAEDF7),
    onSurface: Color(0xFFFAFAFA),
    brightness: Brightness.dark,
  );
}
