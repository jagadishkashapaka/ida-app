import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF0D47A1), // Deep Blue
    brightness: Brightness.light,
  ),
  textTheme: GoogleFonts.interTextTheme(),
  appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
);
