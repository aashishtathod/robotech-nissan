import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  primarySwatch: Colors.grey,
  primaryColor: const Color(0xff2c3539),
  brightness: Brightness.dark,
  backgroundColor: const Color(0xFF212121),
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
  dividerColor: Colors.black12,
);

final lightTheme = ThemeData(
  primaryColor: Colors.white,
  brightness: Brightness.light,
  backgroundColor: Colors.white,
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
  dividerColor: Colors.white54,
);

class Palette {
  static const Color primary = Color(0xFFFF7643);
}
