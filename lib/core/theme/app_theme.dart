import 'package:flutter/material.dart';

class AppTheme {
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFD4AF37), // Gold
      secondary: Color(0xFFC0C0C0), // Silver
      surface: Color(0xFF1E1E1E),
      onPrimary: Colors.black,
      onSurface: Colors.white,
    ),
    fontFamily: 'Roboto',
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.black,
        elevation: 4,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFD4AF37),
        side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
