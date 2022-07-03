import 'package:weather_app/database/database.dart';
import 'package:weather_app/database/entities/saved_location_entity.dart';

class SearchResultLocation {
  final String locationKey;
  final String name;
  final String province;
  final String country;
  bool isAdded;
  String get address => '$country, $province';

  SearchResultLocation({
    this.locationKey = '',
    this.name = '',
    this.province = '',
    this.country = '',
    this.isAdded = false
  });

  /// Convert json object to [SearchResultLocation] object.
  factory SearchResultLocation.fromJson(Map<String, dynamic> json, Database db) => SearchResultLocation(
    locationKey: json['Key'],
    name: json[(json['LocalizedName'].isEmpty)? 'EnglishName' : 'LocalizedName'],
    province: json['AdministrativeArea'][(json['AdministrativeArea']['LocalizedName'].isEmpty)? 'EnglishName' : 'LocalizedName'],
    country: json['Country'][(json['Country']['LocalizedName'].isEmpty)? 'EnglishName' : 'LocalizedName'],
    isAdded: SavedLocation.isAdded(db, locationKey: json['Key'])
  );

  /// Convert json array to list of [SearchResultLocation] object.
  static List<SearchResultLocation> fromJsonArray(List<dynamic> jsonArray, Database db) {
    List<SearchResultLocation> locationsList = [];
    for (dynamic location in jsonArray) {
      locationsList.add(SearchResultLocation.fromJson(location, db));
    }
    return locationsList;
  }
}