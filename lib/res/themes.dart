import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_app/res/colors.dart';

extension ThemeExtension on ThemeData {
  // Get StatusBar & NavigationBar style based on current theme.
  SystemUiOverlayStyle get uiOverlayStyle {
    if (brightness == Brightness.dark) {
      return const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Palette.darkBlue,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: null
      );
    } else {
      return const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Palette.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: null
      );
    }
  }
}