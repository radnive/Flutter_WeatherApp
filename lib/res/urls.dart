import 'package:location/location.dart';
import 'package:weather_app/models/api_keys.dart';

class Urls {
  // AccuWeather base url address.
  static const String baseUrl = 'http://dataservice.accuweather.com';

  // ManageLocations page urls.
  /// Search location by its name.
  static Uri searchLocationByName(String textQuery, {String locale = 'en'}) {
    // Check for language.
    final String lang = (locale != 'en')? '&language=$locale' : '';
    // Create Uri.
    return Uri.parse('$baseUrl/locations/v1/cities/autocomplete?${ApiKeys.accuweather}&q=${textQuery.toLowerCase()}$lang');
  }

  /// Search location by its key.
  static Uri searchLocationByKey(String locationKey) =>
    Uri.parse('$baseUrl/locations/v1/$locationKey?${ApiKeys.accuweather}&language=fa');

  /// Search location by LocationData.
  /// For user location.
  static Uri searchLocationByData(LocationData location, {String locale = 'en'}) {
    // Check for language.
    final String lang = (locale != 'en')? '&language=$locale' : '';
    // Get location latitude and longitude.
    final String geoLocation = '${location.latitude}%2C${location.longitude}';
    // Create Uri.
    return Uri.parse('$baseUrl/locations/v1/cities/geoposition/search?${ApiKeys.accuweather}&q=$geoLocation$lang');
  }
}