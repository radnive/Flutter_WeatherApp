// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_conditions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrentWeather _$CurrentWeatherFromJson(Map<String, dynamic> json) =>
    CurrentWeather(
      dateTime: DateTime.parse(json['dateTime'] as String),
      weatherText: json['weatherText'] as String? ?? '--',
      weatherIcon: json['weatherIcon'] as int? ?? 0,
      temperatureC: (json['temperatureC'] as num?)?.toDouble() ?? 0,
      temperatureF: (json['temperatureF'] as num?)?.toDouble() ?? 0,
      realFeelTemperatureC:
          (json['realFeelTemperatureC'] as num?)?.toDouble() ?? 0,
      realFeelTemperatureF:
          (json['realFeelTemperatureF'] as num?)?.toDouble() ?? 0,
      humidity: json['humidity'] as int? ?? 0,
      windSpeedKmh: (json['windSpeedKmh'] as num?)?.toDouble() ?? 0,
      windSpeedMih: (json['windSpeedMih'] as num?)?.toDouble() ?? 0,
      uvIndex: json['uvIndex'] as int? ?? 0,
      uvIndexText: json['uvIndexText'] as String? ?? '--',
      visibilityKm: (json['visibilityKm'] as num?)?.toDouble() ?? 0,
      visibilityMi: (json['visibilityMi'] as num?)?.toDouble() ?? 0,
      pressureInHg: (json['pressureInHg'] as num?)?.toDouble() ?? 0,
      pressureMb: (json['pressureMb'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$CurrentWeatherToJson(CurrentWeather instance) =>
    <String, dynamic>{
      'dateTime': instance.dateTime.toIso8601String(),
      'weatherText': instance.weatherText,
      'weatherIcon': instance.weatherIcon,
      'temperatureC': instance.temperatureC,
      'temperatureF': instance.temperatureF,
      'realFeelTemperatureC': instance.realFeelTemperatureC,
      'realFeelTemperatureF': instance.realFeelTemperatureF,
      'humidity': instance.humidity,
      'windSpeedKmh': instance.windSpeedKmh,
      'windSpeedMih': instance.windSpeedMih,
      'uvIndex': instance.uvIndex,
      'uvIndexText': instance.uvIndexText,
      'visibilityKm': instance.visibilityKm,
      'visibilityMi': instance.visibilityMi,
      'pressureInHg': instance.pressureInHg,
      'pressureMb': instance.pressureMb,
    };

HourlyForecast _$HourlyForecastFromJson(Map<String, dynamic> json) =>
    HourlyForecast(
      dateTime: DateTime.parse(json['dateTime'] as String),
      weatherIcon: json['weatherIcon'] as int? ?? 0,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$HourlyForecastToJson(HourlyForecast instance) =>
    <String, dynamic>{
      'dateTime': instance.dateTime.toIso8601String(),
      'weatherIcon': instance.weatherIcon,
      'temperature': instance.temperature,
    };
