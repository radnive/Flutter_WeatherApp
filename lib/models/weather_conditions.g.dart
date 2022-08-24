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
      temperatureC: (json['temperatureC'] as num?)?.toDouble(),
      temperatureF: (json['temperatureF'] as num?)?.toDouble(),
      realFeelTemperatureC:
          (json['realFeelTemperatureC'] as num?)?.toDouble() ?? 0,
      realFeelTemperatureF:
          (json['realFeelTemperatureF'] as num?)?.toDouble() ?? 0,
      humidity: json['humidity'] as int?,
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
      temperature: (json['temperature'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$HourlyForecastToJson(HourlyForecast instance) =>
    <String, dynamic>{
      'dateTime': instance.dateTime.toIso8601String(),
      'weatherIcon': instance.weatherIcon,
      'temperature': instance.temperature,
    };

SunStatus _$SunStatusFromJson(Map<String, dynamic> json) => SunStatus(
      sunrise: json['sunrise'] as String? ?? '',
      sunset: json['sunset'] as String? ?? '',
      dayLength: json['dayLength'] as String? ?? '',
      currentTime: json['currentTime'] as String? ?? '',
    );

Map<String, dynamic> _$SunStatusToJson(SunStatus instance) => <String, dynamic>{
      'sunrise': instance.sunrise,
      'sunset': instance.sunset,
      'dayLength': instance.dayLength,
      'currentTime': instance.currentTime,
    };

AirQualityIndex _$AirQualityIndexFromJson(Map<String, dynamic> json) =>
    AirQualityIndex(
      overall: AqiValue.fromJson(json['overall'] as Map<String, dynamic>),
      pm10: AqiValue.fromJson(json['pm10'] as Map<String, dynamic>),
      pm2_5: AqiValue.fromJson(json['pm2_5'] as Map<String, dynamic>),
      co: AqiValue.fromJson(json['co'] as Map<String, dynamic>),
      no2: AqiValue.fromJson(json['no2'] as Map<String, dynamic>),
      so2: AqiValue.fromJson(json['so2'] as Map<String, dynamic>),
      o3: AqiValue.fromJson(json['o3'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AirQualityIndexToJson(AirQualityIndex instance) =>
    <String, dynamic>{
      'overall': instance.overall.toJson(),
      'pm10': instance.pm10.toJson(),
      'pm2_5': instance.pm2_5.toJson(),
      'co': instance.co.toJson(),
      'no2': instance.no2.toJson(),
      'so2': instance.so2.toJson(),
      'o3': instance.o3.toJson(),
    };

AqiValue _$AqiValueFromJson(Map<String, dynamic> json) => AqiValue(
      value: json['value'] as int,
      scale: json['scale'] as int? ?? 0,
      maxValue: json['maxValue'] as int? ?? 0,
    );

Map<String, dynamic> _$AqiValueToJson(AqiValue instance) => <String, dynamic>{
      'value': instance.value,
      'scale': instance.scale,
      'maxValue': instance.maxValue,
    };

WeatherForecast _$WeatherForecastFromJson(Map<String, dynamic> json) =>
    WeatherForecast(
      dateTime: DateTime.parse(json['dateTime'] as String),
      temperature: (json['temperature'] as num?)?.toDouble(),
      iconIndex: json['iconIndex'] as int? ?? 0,
    );

Map<String, dynamic> _$WeatherForecastToJson(WeatherForecast instance) =>
    <String, dynamic>{
      'dateTime': instance.dateTime.toIso8601String(),
      'temperature': instance.temperature,
      'iconIndex': instance.iconIndex,
    };
