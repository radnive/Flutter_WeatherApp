import 'package:flutter/material.dart';

class Types {
  // Main text styles.
  static TextStyle headline1 = const TextStyle(fontWeight: FontWeight.w300, fontSize: 96);
  static TextStyle headline2 = const TextStyle(fontWeight: FontWeight.w300, fontSize: 60);
  static TextStyle headline3 = const TextStyle(fontWeight: FontWeight.w400, fontSize: 48);
  static TextStyle headline4 = const TextStyle(fontWeight: FontWeight.w400, fontSize: 34);
  static TextStyle headline5 = const TextStyle(fontWeight: FontWeight.w400, fontSize: 24);
  static TextStyle headline6 = const TextStyle(fontWeight: FontWeight.w500, fontSize: 20);
  static TextStyle subtitle1 = const TextStyle(fontWeight: FontWeight.w400, fontSize: 16);
  static TextStyle subtitle2 = const TextStyle(fontWeight: FontWeight.w500, fontSize: 14);
  static TextStyle bodyText1 = const TextStyle(fontWeight: FontWeight.w400, fontSize: 16);
  static TextStyle bodyText2 = const TextStyle(fontWeight: FontWeight.w400, fontSize: 14);
  static TextStyle button = const TextStyle(fontWeight: FontWeight.w500, fontSize: 14);
  static TextStyle caption = const TextStyle(fontWeight: FontWeight.w400, fontSize: 12);
  static TextStyle overline = const TextStyle(fontWeight: FontWeight.w400, fontSize: 10);
  // Other text styles.
  static TextStyle introPageText = const TextStyle(fontWeight: FontWeight.w700, fontSize: 48);
  static TextStyle currentTemperature = const TextStyle(fontWeight: FontWeight.w700, fontSize: 88);
  static TextStyle aqiValue = const TextStyle(fontWeight: FontWeight.w600, fontSize: 30);
  static TextStyle savedLocationTemperature = const TextStyle(fontWeight: FontWeight.w600, fontSize: 45);
  static TextStyle multiSelectItemText = const TextStyle(fontWeight: FontWeight.w600, fontSize: 24);
  static TextStyle messageTitle = const TextStyle(fontWeight: FontWeight.w600, fontSize: 20);
  static TextStyle foundedLocationTitle = const TextStyle(fontWeight: FontWeight.w500, fontSize: 18);

  // Create TextTheme.
  static TextTheme get textTheme => ThemeData().textTheme.copyWith(
    headline1: headline1,
    headline2: headline2,
    headline3: headline3,
    headline4: headline4,
    headline5: headline5,
    headline6: headline6,
    subtitle1: subtitle1,
    subtitle2: subtitle2,
    bodyText1: bodyText1,
    bodyText2: bodyText2,
    button: button,
    caption: caption,
    overline: overline
  );

  // Get textTheme.
  static TextTheme of(BuildContext context) => Theme.of(context).textTheme;
}

extension TextThemeExtension on TextTheme {
  // Custom text styles.
  TextStyle get introPageText => Types.introPageText;
  TextStyle get currentTemperature => Types.currentTemperature;
  TextStyle get aqiValue => Types.aqiValue;
  TextStyle get savedLocationTemperature => Types.savedLocationTemperature;
  TextStyle get multiSelectItemText => Types.multiSelectItemText;
  TextStyle get messageTitle => Types.messageTitle;
  TextStyle get foundedLocationTitle => Types.foundedLocationTitle;
}