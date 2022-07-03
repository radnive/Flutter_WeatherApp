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
