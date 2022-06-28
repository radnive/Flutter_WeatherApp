import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum Language {
  persian('IranSansMobile', 'fa'),
  english('Poppins', 'en');

  final String fontFamily;
  final String locale;
  const Language(this.fontFamily, this.locale);
  factory Language.get(int index) => Language.values[index];
  static bool isEnglish(int langIndex) => langIndex == 1;
}

class AppearanceChangeProvider extends ChangeNotifier {
  AppearanceChangeProvider({
    this.language = Language.english,
    this.themeMode = ThemeMode.system
  });
  // :: Language
  Language language;
  setLanguage(Language language) {
    this.language = language;
    notifyListeners();
  }
  // :: ThemeMode
  ThemeMode themeMode;
  setThemeMode(ThemeMode mode) {
    themeMode = mode;
    notifyListeners();
  }
}

extension BuildContextExtension on BuildContext {
  AppearanceChangeProvider get appearanceProvider => read<AppearanceChangeProvider>();
}