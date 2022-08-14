import 'package:flutter/material.dart' show ColorScheme, Color;
import 'package:weather_app/res/colors.dart' show ColorSchemeExtension;
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_app/extensions/date.dart';
part 'weather_conditions.g.dart';

const int nullIconIndexValue = 0;

@JsonSerializable()
class CurrentWeather {
  final DateTime dateTime;
  Date get date => Date(dateTime);
  final String weatherText;
  final int weatherIcon;
  final double? temperatureC;
  final double? temperatureF;
  final double realFeelTemperatureC;
  final double realFeelTemperatureF;
  final int? humidity;
  final double windSpeedKmh;
  final double windSpeedMih;
  final int uvIndex;
  final String uvIndexText;
  final double visibilityKm;
  final double visibilityMi;
  final double pressureInHg;
  final double pressureMb;

  double? getTemperature(bool isMetric) => (isMetric)? temperatureC : temperatureF;
  int getRealFeelTemperature(bool isMetric) =>
      ((isMetric)? realFeelTemperatureC : realFeelTemperatureF).toInt();
  int getWindSpeed(bool isMetric) =>
      ((isMetric)? windSpeedKmh : windSpeedMih).toInt();
  int getVisibility(bool isMetric) =>
      ((isMetric)? visibilityKm : visibilityMi).toInt();


  factory CurrentWeather.empty() => CurrentWeather(dateTime: DateTime.now());

  CurrentWeather({
    required this.dateTime,
    this.weatherText = '--',
    this.weatherIcon = 0,
    this.temperatureC,
    this.temperatureF,
    this.realFeelTemperatureC = 0,
    this.realFeelTemperatureF = 0,
    this.humidity,
    this.windSpeedKmh = 0,
    this.windSpeedMih = 0,
    this.uvIndex = 0,
    this.uvIndexText = '--',
    this.visibilityKm = 0,
    this.visibilityMi = 0,
    this.pressureInHg = 0,
    this.pressureMb = 0
  });

  factory CurrentWeather.fromJsonRes(Map<String, dynamic> json) => CurrentWeather(
    dateTime: DateTime.fromMillisecondsSinceEpoch(json['EpochTime'] * 1000, isUtc: true),
    weatherText: json['WeatherText'],
    weatherIcon: (json.containsKey('WeatherIcon'))? json['WeatherIcon'] : nullIconIndexValue,
    temperatureC: (json['Temperature']['Metric'].containsKey('Value'))? json['Temperature']['Metric']['Value'] : null,
    temperatureF: (json['Temperature']['Imperial'].containsKey('Value'))? json['Temperature']['Imperial']['Value'] : null,
    realFeelTemperatureC: json['RealFeelTemperature']['Metric']['Value'],
    realFeelTemperatureF: json['RealFeelTemperature']['Imperial']['Value'],
    humidity: (json.containsKey('RelativeHumidity'))? json['RelativeHumidity'] : null,
    windSpeedKmh: json['Wind']['Speed']['Metric']['Value'],
    windSpeedMih: json['Wind']['Speed']['Imperial']['Value'],
    uvIndex: json['UVIndex'],
    uvIndexText: json['UVIndexText'],
    visibilityKm: json['Visibility']['Metric']['Value'],
    visibilityMi: json['Visibility']['Imperial']['Value'],
    pressureMb: json['Pressure']['Metric']['Value'],
    pressureInHg: json['Pressure']['Imperial']['Value']
  );

  factory CurrentWeather.fromJson(Map<String, dynamic> json) => _$CurrentWeatherFromJson(json);
  Map<String, dynamic> toJson() => _$CurrentWeatherToJson(this);
}

@JsonSerializable()
class HourlyForecast {
  final DateTime dateTime;
  Date get date => Date(dateTime);
  final int weatherIcon;
  final double? temperature;

  HourlyForecast({required this.dateTime, this.weatherIcon = 0, this.temperature});

  factory HourlyForecast.fromJsonRes(Map<String, dynamic> json) => HourlyForecast(
    dateTime: DateTime.fromMillisecondsSinceEpoch(json['EpochDateTime'] * 1000, isUtc: false),
    weatherIcon: (json.containsKey('WeatherIcon'))? json['WeatherIcon'] : nullIconIndexValue,
    temperature: (json['Temperature'].containsKey('Value'))? json['Temperature']['Value'] : null
  );

  static List<HourlyForecast> fromJsonArrayRes(List<dynamic> jsonArray) {
    List<HourlyForecast> list = [];
    for(Map<String, dynamic> hf in jsonArray) {
      list.add(HourlyForecast.fromJsonRes(hf));
    }
    return list;
  }

  factory HourlyForecast.fromJson(Map<String, dynamic> json) => _$HourlyForecastFromJson(json);
  Map<String, dynamic> toJson() => _$HourlyForecastToJson(this);
}

@JsonSerializable()
class SunStatus {
  final String sunrise;
  final String sunset;
  final String dayLength;
  final String currentTime;
  double get sunProgress {
    // If object doesn't initialized.
    if (dayLength.isEmpty) { return 0; }
    // Calculate values.
    int nowInSeconds = _stringTimeToInt(currentTime);
    int sunriseInSeconds = _stringTimeToInt(sunrise);
    int sunsetInSeconds = _stringTimeToInt(sunset);
    int dayLengthInSeconds = _stringTimeToInt(dayLength);
    // If sunset already happened.
    if (nowInSeconds >= sunsetInSeconds) { return 100; }
    // If sun still in the sky.
    return ((nowInSeconds - sunriseInSeconds) * 100) / dayLengthInSeconds;
  }
  SunStatus({this.sunrise = '', this.sunset = '', this.dayLength = '', this.currentTime = ''});

  factory SunStatus.fromJsonRes(Map<String, dynamic> json) => SunStatus(
      sunrise: json['sunrise'],
      sunset: json['sunset'],
      dayLength: json['day_length'],
      currentTime: json['current_time'].split('.')[0]
  );

  factory SunStatus.fromJson(Map<String, dynamic> json) => _$SunStatusFromJson(json);
  Map<String, dynamic> toJson() => _$SunStatusToJson(this);

  /// Convert string time to int.
  int _stringTimeToInt(String time) {
    if (time.isEmpty) { return 0; }

    int output = 0;
    List<int> inSec = [3600, 60, 1];
    List<String> parts = time.split(':');

    if(parts.isEmpty) { return 0; }

    for(int index = 0; index < parts.length; index++) {
      output += (int.parse(parts[index]) * inSec[index]);
    }
    return output;
  }
}

@JsonSerializable()
class AirQualityIndex {
  final AqiValue overall, pm10, pm2_5, co, no2, so2, o3;

  AirQualityIndex({
    required this.overall,
    required this.pm10,
    required this.pm2_5,
    required this.co,
    required this.no2,
    required this.so2,
    required this.o3
  });

  factory AirQualityIndex.empty() => AirQualityIndex(
    overall: AqiValue(value: 0),
    pm10: AqiValue(value: 0),
    pm2_5: AqiValue(value: 0),
    co: AqiValue(value: 0),
    no2: AqiValue(value: 0),
    so2: AqiValue(value: 0),
    o3: AqiValue(value: 0)
  );

  factory AirQualityIndex.fromJsonRes(Map<String, dynamic> json) => AirQualityIndex(
    overall: AqiValue.create(value: json['overall_aqi'], scales: AqiScales.aqiScale),
    pm10: AqiValue.create(value: json['PM10']['aqi'], scales: AqiScales.pm10Scale),
    pm2_5: AqiValue.create(value: json['PM2.5']['aqi'], scales: AqiScales.pm2_5Scale),
    co: AqiValue.create(value: json['CO']['aqi'], scales: AqiScales.coScale),
    no2: AqiValue.create(value: json['NO2']['aqi'], scales: AqiScales.no2Scale),
    so2: AqiValue.create(value: json['SO2']['aqi'], scales: AqiScales.so2Scale),
    o3: AqiValue.create(value: json['O3']['aqi'], scales: AqiScales.o3Scale)
  );

  factory AirQualityIndex.fromJson(Map<String, dynamic> json) => _$AirQualityIndexFromJson(json);
  Map<String, dynamic> toJson() => _$AirQualityIndexToJson(this);
}

@JsonSerializable()
class AqiValue {
  final int value;
  final int scale;
  final int maxValue;
  double get percent => (value * 100) / maxValue;

  AqiValue({required this.value, this.scale = 0, this.maxValue = 0});

  factory AqiValue.create({required int value, required List<IntRange> scales}) => AqiValue(
    value: value,
    scale: getScale(value, scales),
    maxValue: scales.last.endOffset
  );

  factory AqiValue.fromJson(Map<String, dynamic> json) => _$AqiValueFromJson(json);
  Map<String, dynamic> toJson() => _$AqiValueToJson(this);

  /// Get Scale based on value.
  static int getScale(int currentValue, List<IntRange> scales) {
    if(scales.last.endOffset <= currentValue) return scales.length - 1;

    for (int i = 0; i < scales.length; i++) {
      if (scales[i].contains(currentValue)) {
        return i;
      }
    }

    return 0;
  }

  /// Get color based on scale value.
  Color getColor(ColorScheme palette) {
    switch (scale) {
      case 0 : return palette.info; // <- Excellent
      case 1 : return palette.success; // <- Good
      case 2 : return palette.warning; // <- Fair
      case 3 : return palette.seriousWarning; // <- Poor
      case 4 : return palette.error; // <- Unhealthy
      case 5 : return palette.danger; // <- Dangerous
      default: return palette.onBackground;
    }
  }
}

class IntRange {
  int startOffset;
  int endOffset;
  IntRange(this.startOffset, this.endOffset);

  bool contains(int value) => (startOffset <= value) && (endOffset >= value);
}

class AqiScales {
  // Scale ranges.
  static List<IntRange> aqiScale = [
    IntRange(0, 19), // <- Excellent
    IntRange(20, 49), // <- Good
    IntRange(50, 99), // <- Fair
    IntRange(100, 149), // <- Poor
    IntRange(150, 249), // <- Unhealthy
    IntRange(250, 500) // <- Dangerous
  ];

  static List<IntRange> pm10Scale = [
    IntRange(0, 12), // <- Excellent
    IntRange(13, 25), // <- Good
    IntRange(26, 50), // <- Fair
    IntRange(51, 90), // <- Poor
    IntRange(91, 180), // <- Unhealthy
    IntRange(180, 250), // <- Dangerous
  ];

  static List<IntRange> pm2_5Scale = [
    IntRange(0, 7), // <- Excellent
    IntRange(8, 15), // <- Good
    IntRange(16, 30), // <- Fair
    IntRange(31, 55), // <- Poor
    IntRange(56, 110), // <- Unhealthy
    IntRange(110, 170), // <- Dangerous
  ];

  static List<IntRange> coScale = [
    IntRange(0, 2), // <- Excellent
    IntRange(3, 5), // <- Good
    IntRange(6, 8), // <- Fair
    IntRange(9, 30), // <- Poor
    IntRange(31, 100), // <- Unhealthy
    IntRange(101, 150), // <- Dangerous
  ];

  static List<IntRange> no2Scale = [
    IntRange(0, 25), // <- Excellent
    IntRange(26, 50), // <- Good
    IntRange(51, 100), // <- Fair
    IntRange(101, 200), // <- Poor
    IntRange(201, 400), // <- Unhealthy
    IntRange(401, 500), // <- Dangerous
  ];

  static List<IntRange> so2Scale = [
    IntRange(0, 25), // <- Excellent
    IntRange(26, 50), // <- Good
    IntRange(51, 120), // <- Fair
    IntRange(121, 350), // <- Poor
    IntRange(351, 500), // <- Unhealthy
    IntRange(501, 550), // <- Dangerous
  ];

  static List<IntRange> o3Scale = [
    IntRange(0, 32), // <- Excellent
    IntRange(33, 64), // <- Good
    IntRange(65, 119), // <- Fair
    IntRange(120, 179), // <- Poor
    IntRange(180, 239), // <- Unhealthy
    IntRange(240, 280), // <- Dangerous
  ];
}

@JsonSerializable()
class WeatherForecast {
  final DateTime dateTime;
  Date get date => Date(dateTime);
  final double? temperature;
  final int iconIndex;
  const WeatherForecast({
    required this.dateTime,
    this.temperature,
    this.iconIndex = 0
  });

  factory WeatherForecast.empty() => WeatherForecast(dateTime: DateTime.now());

  factory WeatherForecast.fromJsonRes(Map<String, dynamic> json) => WeatherForecast(
    dateTime: DateTime.fromMillisecondsSinceEpoch(json['EpochDate'] * 1000, isUtc: true),
    temperature: (json['Temperature']['Maximum'].containsKey('Value'))? json['Temperature']['Maximum']['Value'] : null,
    iconIndex: json['Day']['Icon']
  );

  static List<WeatherForecast> fromJsonArrayRes(Map<String, dynamic> json) {
    List<WeatherForecast> items = [];
    List<dynamic> jsonArray = json['DailyForecasts'];
    for(int index = 1; index < jsonArray.length; index ++) {
      items.add(WeatherForecast.fromJsonRes(jsonArray[index]));
    }
    return items;
  }

  factory WeatherForecast.fromJson(Map<String, dynamic> json) => _$WeatherForecastFromJson(json);
  Map<String, dynamic> toJson() => _$WeatherForecastToJson(this);
}
