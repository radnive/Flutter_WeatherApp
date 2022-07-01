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
    return Uri.parse('$baseUrl/locations/v1/cities/autocomplete?${ApiKeys.accuweather}&q=$textQuery$lang');
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

  /// Get top 50 locations.
  static Uri popularLocations() =>
    Uri.parse('$baseUrl/locations/v1/topcities/50?${ApiKeys.accuweather}&language=fa');

  // Home page urls.
  /// Get current weather conditions.
  static Uri currentCondition(String locationKey, {bool details = true, String locale = 'en'}) {
    // Check for language.
    final String lang = (locale != 'en')? '&language=$locale' : '';
    // Check for details.
    final String getDetails = (details)? '&details=true' : '';
    // Create Uri.
    return Uri.parse('$baseUrl/currentconditions/v1/$locationKey?${ApiKeys.accuweather}$lang$getDetails');
  }
}