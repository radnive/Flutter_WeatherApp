import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import 'package:weather_app/database/database.dart';
import 'package:weather_app/provider.dart';

enum TemperatureUnit {
  c('C'), f('F');
  final String text;
  const TemperatureUnit(this.text);
  factory TemperatureUnit.get(int index) => TemperatureUnit.values[index];
  static bool isItMetric(int index) => index == 0;
  bool get isMetric => index == 0;
}

enum WindSpeedUnit {
  kmh('km/h'), mih('mi/h');
  final String text;
  const WindSpeedUnit(this.text);
  factory WindSpeedUnit.get(int index) => WindSpeedUnit.values[index];
  static isItMetric(int index) => index == 0;
  bool get isMetric => index == 0;
}

enum VisibilityUnit {
  km, mi;
  const VisibilityUnit();
  factory VisibilityUnit.get(int index) => VisibilityUnit.values[index];
  static isItMetric(int index) => index == 0;
  bool get isMetric => index == 0;
}

@Entity()
@Unique(onConflict: ConflictStrategy.replace)
class Settings {
  @Id(assignable: true)
  int id;
  int temperatureUnit;
  int windSpeedUnit;
  int visibilityUnit;
  int language;
  int themeMode;
  bool autoUpdate;

  // Create settings.
  Settings({
    this.temperatureUnit = 0,
    this.windSpeedUnit = 0,
    this.visibilityUnit = 0,
    this.language = 1,
    this.themeMode = 1,
    this.autoUpdate = false
  }) : id = 9;

  // Get user settings index.
  TemperatureUnit get getTemperatureUnit => TemperatureUnit.get(temperatureUnit);
  WindSpeedUnit get getWindSpeedUnit => WindSpeedUnit.get(windSpeedUnit);
  VisibilityUnit get getVisibilityUnit => VisibilityUnit.get(visibilityUnit);
  Language get getLanguage => Language.get(language);
  ThemeMode get getThemeMode => ThemeMode.values[themeMode];

  // Update part of user settings object.
  Settings apply({
    int? temperatureUnit,
    int? windSpeedUnit,
    int? visibilityUnit,
    int? language,
    int? themeMode,
    bool? autoUpdate
  }) {
    if (temperatureUnit != null) { this.temperatureUnit = temperatureUnit; }
    if (windSpeedUnit != null) { this.windSpeedUnit = windSpeedUnit; }
    if (visibilityUnit != null) { this.visibilityUnit = visibilityUnit; }
    if (language != null) { this.language = language; }
    if (themeMode != null) { this.themeMode = themeMode; }
    if (autoUpdate != null) { this.autoUpdate = autoUpdate; }
    return this;
  }

  // Just copy.
  Settings copy() => Settings(
    temperatureUnit: temperatureUnit,
    windSpeedUnit: windSpeedUnit,
    visibilityUnit: visibilityUnit,
    language: language,
    themeMode: themeMode,
    autoUpdate: autoUpdate
  );

  // Copy settings with new properties value.
  Settings copyWith({
    int? temperatureUnit,
    int? windSpeedUnit,
    int? visibilityUnit,
    int? language,
    int? themeMode,
    bool? autoUpdate
  }) {
    return Settings(
      temperatureUnit: (temperatureUnit != null)? temperatureUnit : this.temperatureUnit,
      windSpeedUnit: (windSpeedUnit != null)? windSpeedUnit : this.windSpeedUnit,
      visibilityUnit: (visibilityUnit != null)? visibilityUnit : this.visibilityUnit,
      language: (language != null)? language : this.language,
      themeMode: (themeMode != null)? themeMode : this.themeMode,
      autoUpdate: (autoUpdate != null)? autoUpdate : this.autoUpdate
    );
  }

  // CRUD functions.
  // :: Check for user settings.
  static bool isSettingsSaved(Database db) => db.store.box<Settings>().contains(9);
  // :: Get user settings.
  static Settings get(Database db) => db.store.box<Settings>().get(9)!;
  // :: Insert default settings.
  static void insertDefaultSettings(Database db) {
    db.store.box<Settings>().put(
      Settings(
        temperatureUnit: 0, // <- C
        windSpeedUnit: 0, // <- km/h
        visibilityUnit: 0, // <- km
        language: 1, // <- English
        themeMode: 0, // <- System
        autoUpdate: true,
      )
    );
  }
  // :: Update user settings.
  void update(Database db) => db.store.box<Settings>().put(this);
}
