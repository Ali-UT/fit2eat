import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _lightGreen = Color(0xFFA5D6A7);
  static const Color _offWhite = Color(0xFFF5F5F5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _lightGreen,
        brightness: Brightness.light,
        primary: _lightGreen,
        background: _offWhite,
        surface: _offWhite, // Or a slightly different shade if needed
      ),
      scaffoldBackgroundColor: _offWhite,
      appBarTheme: AppBarTheme(
        backgroundColor: _lightGreen,
        foregroundColor: Colors.black, // Or Colors.white depending on contrast
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w500, // Medium weight
          fontSize: 20,
          color: Colors.black, // Or Colors.white
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(fontSize: 57, fontWeight: FontWeight.w400),
        displayMedium: GoogleFonts.inter(fontSize: 45, fontWeight: FontWeight.w400),
        displaySmall: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w400),
        headlineLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w400),
        headlineMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w400),
        headlineSmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w400),
        titleLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w500),
        titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
        titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
        bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25),
        labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.5),
        labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, letterSpacing: 0.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightGreen,
          foregroundColor: Colors.black, // Text color on button
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      // Add other theme properties as needed (e.g., inputDecorationTheme, cardTheme, etc.)
    );
  }
}