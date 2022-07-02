import 'dart:convert';
import 'package:weather_app/database/database.dart';
import 'package:weather_app/extensions/list.dart';
import 'package:weather_app/extensions/map.dart';
import 'package:weather_app/models/weather_conditions.dart';
import 'package:weather_app/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
@Unique(onConflict: ConflictStrategy.replace)
class HomePageData {
  @Id(assignable: true)
  int id;
  String locationKey;
  DateTime date;
  String currentWeather;
  List<String> hourlyForecasts;
  String sunStatus;
  List<String> weatherForecasts;

  bool get isUpToDate => DateTime.now().difference(date).inHours <= 1;
  CurrentWeather get savedCurrentWeather => CurrentWeather.fromJson(jsonDecode(currentWeather));
  List<HourlyForecast> get savedHourlyForecasts => hourlyForecasts.to<HourlyForecast>(
          (hf) => HourlyForecast.fromJson(jsonDecode(hf)));
  SunStatus get savedSunStatus => SunStatus.fromJson(jsonDecode(sunStatus));
  List<WeatherForecast> get savedWeatherForecast => weatherForecasts.to<WeatherForecast>(
          (wf) => WeatherForecast.fromJson(jsonDecode(wf)));

  HomePageData({
    this.id = 9,
    required this.locationKey,
    required this.date,
    this.currentWeather = '',
    this.hourlyForecasts = const [],
    this.sunStatus = '',
    this.weatherForecasts = const []
  });

  factory HomePageData.from({
    required String locationKey,
    required CurrentWeather currentWeather,
    required List<HourlyForecast> hourlyForecasts,
    required SunStatus sunStatus,
    required List<WeatherForecast> weatherForecasts
  }) => HomePageData(
      locationKey: locationKey,
      date: DateTime.now(),
      currentWeather: currentWeather.toJson().toJsonStr,
      hourlyForecasts: hourlyForecasts.to<String>((hf) => hf.toJson().toJsonStr),
      sunStatus: sunStatus.toJson().toJsonStr,
      weatherForecasts: weatherForecasts.to<String>((wf) => wf.toJson().toJsonStr)
  );

  /// Look through database for saved data for [locationKey]
  static bool isDataSavedFor(Database db, String locationKey) {
    final data = get(db);
    if(data != null) {
      return data.locationKey == locationKey;
    } else {
      return false;
    }
  }

  /// Get saved data from database.
  static HomePageData? get(Database db) => db.store.box<HomePageData>().get(9);

  /// Put new data to database.
  void put(Database db) => db.store.box<HomePageData>().put(this);
}
