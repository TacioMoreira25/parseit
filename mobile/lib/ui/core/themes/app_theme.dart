import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class to define the application's theme.
class AppTheme {
  // Private constructor
  AppTheme._();

  /// The main theme of the application.
  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: const Color(0xFFF5F5F7),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F5F7),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00695C), // Dark Teal
        background: const Color(0xFFF5F5F7),
      ),
      useMaterial3: true,
    );
  }
}
