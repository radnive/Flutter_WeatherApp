import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import 'package:weather_app/database/database.dart';
import 'package:weather_app/provider.dart';

enum TemperatureUnit {
  c('C'), f('F');
  final String text;
  const TemperatureUnit(this.text);
  factory TemperatureUnit.get(int index) => TemperatureUnit.values[index];
  static bool isMetric(int index) => index == 0;
}

enum WindSpeedUnit {
  kmh('km/h'), mih('mi/h');
  final String text;
  const WindSpeedUnit(this.text);
  factory WindSpeedUnit.get(int index) => WindSpeedUnit.values[index];
  static bool isMetric(int index) => index == 0;
}

enum VisibilityUnit {
  km, mi;
  const VisibilityUnit();
  factory VisibilityUnit.get(int index) => VisibilityUnit.values[index];
  static bool isMetric(int index) => index == 0;
}

@Entity()
@Unique(onConflict: ConflictStrategy.replace)
class Settings {
  @Id(assignable: true)
  int id;
  int _temperatureUnit;
  int _windSpeedUnit;
  int _visibilityUnit;
  int _language;
  int _themeMode;
  bool autoUpdate;

  // Create settings.
  Settings({
    int temperatureUnit = 0,
    int windSpeedUnit = 0,
    int visibilityUnit = 0,
    int language = 1,
    int themeMode = 1,
    this.autoUpdate = false
  }) :
    id = 9,
    _temperatureUnit = temperatureUnit,
    _windSpeedUnit = windSpeedUnit,
    _visibilityUnit = visibilityUnit,
    _language = language,
    _themeMode = themeMode;

  // Get user settings.
  TemperatureUnit get temperatureUnit => TemperatureUnit.get(_temperatureUnit);
  WindSpeedUnit get windSpeedUnit => WindSpeedUnit.get(_windSpeedUnit);
  VisibilityUnit get visibilityUnit => VisibilityUnit.get(_visibilityUnit);
  Language get language => Language.get(_language);
  ThemeMode get themeMode => ThemeMode.values[_themeMode];

  // Update part of user settings object.
  Settings apply({
    int? temperatureUnit,
    int? windSpeedUnit,
    int? visibilityUnit,
    int? language,
    int? themeMode,
    bool? autoUpdate
  }) {
    if (temperatureUnit != null) { _temperatureUnit = temperatureUnit; }
    if (windSpeedUnit != null) { _windSpeedUnit = windSpeedUnit; }
    if (visibilityUnit != null) { _visibilityUnit = visibilityUnit; }
    if (language != null) { _language = language; }
    if (themeMode != null) { _themeMode = themeMode; }
    if (autoUpdate != null) { this.autoUpdate = autoUpdate; }
    return this;
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
