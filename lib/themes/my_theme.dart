import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeClass extends ChangeNotifier {
  ThemeData? currentTheme;

  void setLightMode() {
    currentTheme = ThemeData(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black87,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Color.fromARGB(255, 201, 201, 201)),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedIconTheme: const IconThemeData(color: Colors.black87),
          unselectedIconTheme:
              IconThemeData(color: Colors.black87.withOpacity(0.5)),
          backgroundColor: Colors.white,
          selectedLabelStyle: GoogleFonts.roboto(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        textTheme: TextTheme(
            displayLarge: GoogleFonts.roboto(
                color: Colors.black87,
                fontSize: 50,
                fontWeight: FontWeight.w900),
            titleMedium: GoogleFonts.roboto(
                color: Colors.black87,
                fontSize: 23,
                fontWeight: FontWeight.w900),
            titleSmall: GoogleFonts.roboto(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w700)));
    notifyListeners();
  }

  void setDarkMode() {
    currentTheme = ThemeData(
        backgroundColor: const Color.fromARGB(255, 15, 15, 15),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Color.fromARGB(255, 40, 40, 40)),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color.fromARGB(255, 22, 22, 22),
          selectedIconTheme: const IconThemeData(color: Colors.white),
          unselectedIconTheme: const IconThemeData(color: Colors.white60),
          selectedLabelStyle: GoogleFonts.roboto(
            color: Colors.black87.withOpacity(0.5),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        textTheme: TextTheme(
            displayLarge: GoogleFonts.roboto(
                color: Colors.white, fontSize: 50, fontWeight: FontWeight.w900),
            titleMedium: GoogleFonts.roboto(
                color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900),
            titleSmall: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700)));
    notifyListeners();
  }
}
