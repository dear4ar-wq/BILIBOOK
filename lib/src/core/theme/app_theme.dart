import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Brand Colors
const kNavyPrimary = Color(0xFF1A1F36);
const kNavyDeep = Color(0xFF0D1117);
const kGoldAccent = Color(0xFFD4AF37);
const kGoldMuted = Color(0xFFC5A028);
const kIvoryBackground = Color(0xFFF8F9FA);

final appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: kIvoryBackground,
  
  colorScheme: ColorScheme.fromSeed(
    seedColor: kNavyPrimary,
    brightness: Brightness.light,
    primary: kNavyPrimary,
    secondary: kGoldAccent,
    surface: Colors.white,
    background: kIvoryBackground,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
  ),
  
  // Luxury Typography
  textTheme: GoogleFonts.outfitTextTheme(
    ThemeData.light().textTheme.copyWith(
      displayLarge: const TextStyle(fontWeight: FontWeight.w900, color: kNavyPrimary),
      displayMedium: const TextStyle(fontWeight: FontWeight.w800, color: kNavyPrimary),
      headlineLarge: const TextStyle(fontWeight: FontWeight.w800, color: kNavyPrimary),
      bodyLarge: const TextStyle(fontWeight: FontWeight.w600, color: kNavyDeep),
      bodyMedium: const TextStyle(fontWeight: FontWeight.w500, color: kNavyDeep),
    ),
  ),
  
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    elevation: 0,
    backgroundColor: Colors.white,
    foregroundColor: kNavyPrimary,
    titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: kNavyPrimary),
  ),
  
  cardTheme: CardThemeData(
    elevation: 4,
    shadowColor: kNavyPrimary.withOpacity(0.05),
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: BorderSide(color: kNavyPrimary.withOpacity(0.05)),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: kNavyPrimary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kGoldAccent,
    foregroundColor: Colors.white,
    elevation: 4,
  ),
);
