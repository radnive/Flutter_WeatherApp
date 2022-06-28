import 'package:flutter/material.dart';

class Palette {
  static const Color black = Color(0xff121212);
  static const Color white = Color(0xfff7f7f7);
  static const Color grey = Color(0xffeeeeee);
  static const Color blue = Color(0xff126ef2);
  static const Color skyBlue = Color(0xff5ea1df);
  static const Color darkBlue = Color(0xff020e1f);
  static const Color cyanLight = Color(0xff2cccff);
  static const Color cyan = Color(0xff62b4ff);
  static const Color lightGreen = Color(0xff48ff89);
  static const Color green = Color(0xff3cd278);
  static const Color lightYellow = Color(0xffffff50);
  static const Color yellow = Color(0xffffcc00);
  static const Color lightRed = Color(0xffff755b);
  static const Color red = Color(0xffff463a);
  static const Color lightOrange = Color(0xffffad4d);
  static const Color orange = Color(0xffff9a3d);
  static const Color lightPurple = Color(0xffca93ff);
  static const Color purple = Color(0xffaa52ff);

  // Create light color scheme.
  static ColorScheme get lightColorScheme => ThemeData.light().colorScheme.copyWith(
      primary: Palette.blue,
      onPrimary: Palette.white,
      background: Palette.white,
      onBackground: Palette.black,
      surface: Palette.white,
      onSurface: Palette.black,
      error: Palette.red,
      onError: Palette.white
  );
  // Create dark color scheme.
  static ColorScheme get darkColorScheme => ThemeData.dark().colorScheme.copyWith(
      primary: Palette.blue,
      onPrimary: Palette.white,
      background: Palette.darkBlue,
      onBackground: Palette.white,
      surface: Palette.darkBlue,
      onSurface: Palette.white,
      error: Palette.red,
      onError: Palette.black
  );

  // Get colorScheme.
  static ColorScheme of(BuildContext context) => Theme.of(context).colorScheme;
}

extension ColorSchemeExtension on ColorScheme {
  bool get isOnLightMode => brightness == Brightness.light;
  // :: On something.
  Color get onPrimarySubtitle => Palette.white.withAlpha(122); // alpha = 0.08
  // :: Alerts
  Color get success => (isOnLightMode)? Palette.green : Palette.lightGreen;
  Color get warning => (isOnLightMode)? Palette.yellow : Palette.lightYellow;
  Color get info => (isOnLightMode)? Palette.cyan : Palette.cyanLight;
  Color get seriousWarning => (isOnLightMode)? Palette.orange : Palette.lightOrange;
  Color get danger => (isOnLightMode)? Palette.purple : Palette.lightPurple;
  // :: Other colors.
  Color get subtitle => onBackground.withAlpha(122); // alpha = 0.48
  Color get border => onBackground.withAlpha(40); // alpha = 0.16
  Color get divider => onBackground.withAlpha(20); // alpha = 0.08
  Color get textFieldBackground => onBackground.withAlpha(20); // alpha = 0.08
  Color get blurBackground => background.withAlpha(127); // alpha = 0.5
  Color get cancelButtonBackground => onBackground.withAlpha(20); // alpha = 0.08
  Color get refreshIndicatorNormalBackground => (isOnLightMode)? Palette.grey : Palette.black;
  Color get skyBlueColor => (isOnLightMode)? Palette.skyBlue : Palette.darkBlue;
}
