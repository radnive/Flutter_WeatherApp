class PopularLocation {
  final String namePer;
  final String nameEn;
  const PopularLocation({this.namePer = '', this.nameEn = ''});

  /// Convert json object to [PopularLocation] object.
  factory PopularLocation.fromJson(Map<String, dynamic> json) => PopularLocation(
    namePer: json['LocalizedName'],
    nameEn: json['EnglishName'],
  );

  /// Convert json array to list of [PopularLocation] object.
  static List<PopularLocation> fromJsonArray(List<dynamic> jsonArray) {
    List<PopularLocation> locationsList = [];
    for (dynamic location in jsonArray) {
      locationsList.add(PopularLocation.fromJson(location));
    }
    return locationsList;
  }
}