import 'package:flutter/material.dart';
import 'package:spotify/feature/commons/utility/color_resource.dart';

ThemeData lightTheme = ThemeData(
  fontFamily: 'SanFrancisco',
  brightness: Brightness.light,
  useMaterial3: true,
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
  ),
  appBarTheme: const AppBarTheme(
    color: Colors.blue,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
);


ThemeData darkTheme = ThemeData(
  fontFamily: 'SanFrancisco',
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: ColorResources.primaryColor
  ),
  scaffoldBackgroundColor: ColorResources.primaryColor,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 18, color: Colors.white70),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: ColorResources.secondaryColor
  ),
  appBarTheme: const AppBarTheme(
    color: Colors.red,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.red,
    brightness: Brightness.dark,
  ),
);