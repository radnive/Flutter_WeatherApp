import 'package:objectbox/objectbox.dart';
import 'package:weather_app/database/database.dart';
import 'package:weather_app/objectbox.g.dart' show SavedLocation_;

@Entity()
@Unique(onConflict: ConflictStrategy.replace)
class SavedLocation {
  @Id()
  int id;
  String locationKey;
  String namePer;
  String nameEn;
  String provincePer;
  String provinceEn;
  String countryPer;
  String countryEn;
  double latitude;
  double longitude;
  double temperatureC;
  double temperatureF;
  DateTime lastUpdate;
  bool isPinned;
  String get addressPer => '$countryPer, $provincePer';
  String get addressEn => '$countryEn, $provinceEn';

  /// Get name of SavedLocation based on current app language.
  String getName(String locale) => (locale == 'en')? nameEn : namePer;
  /// Get address of SavedLocation based on current app language.
  String getAddress(String locale) => (locale == 'en')? addressEn : addressPer;
  /// Get saved temperature.
  int getTemperature(bool isMetric) => ((isMetric)? temperatureC : temperatureF).toInt();

  /// Check that is temperature up to date or not.
  bool get isUpToDate => DateTime.now().difference(lastUpdate).inHours <= 1;

  /// Create new object.
  SavedLocation({
    this.id = 0,
    this.locationKey = '',
    this.namePer = '',
    this.nameEn = '',
    this.provincePer = '',
    this.provinceEn = '',
    this.countryPer = '',
    this.countryEn = '',
    this.latitude = 0,
    this.longitude = 0,
    this.temperatureC = 0,
    this.temperatureF = 0,
    required this.lastUpdate,
    this.isPinned = false
  });

  /// Create SavedLocation object from json object.
  factory SavedLocation.fromJson(Map<String, dynamic> json) => SavedLocation(
    locationKey: json['Key'],
    namePer: json['LocalizedName'],
    nameEn: json['EnglishName'],
    provincePer: json['AdministrativeArea']['LocalizedName'],
    provinceEn: json['AdministrativeArea']['EnglishName'],
    countryPer: json['Country']['LocalizedName'],
    countryEn: json['Country']['EnglishName'],
    latitude: json['GeoPosition']['Latitude'],
    longitude: json['GeoPosition']['Longitude'],
    lastUpdate: DateTime.fromMillisecondsSinceEpoch(0)
  );

  /// Apply change on current SavedLocation object.
  SavedLocation apply({
    double? temperatureC,
    double? temperatureF,
    DateTime? lastUpdate,
    bool? isPinned
  }) {
    if (temperatureC != null) { this.temperatureC = temperatureC; }
    if (temperatureF != null) { this.temperatureF = temperatureF; }
    if (lastUpdate != null) { this.lastUpdate = lastUpdate; }
    if (isPinned != null) { this.isPinned = isPinned; }
    return this;
  }

  // CRUD functions.
  /// Get saved locations collection length.
  static int count(Database db) => db.store.box<SavedLocation>().count();

  /// Return TRUE if saved locations collection is empty.
  static bool isCollectionEmpty(Database db) => count(db) == 0;

  /// Find pinned location.
  static SavedLocation? pinnedLocation(Database db) =>
      db.store.box<SavedLocation>().query(SavedLocation_.isPinned.equals(true)).build().findFirst();

  /// Get all saved locations.
  static List<SavedLocation> getAll(Database db) {
    // Create search query.
    final QueryBuilder<SavedLocation> queryBuilder = db.store.box<SavedLocation>().query()
      ..order(SavedLocation_.isPinned, flags: 1)
      ..order(SavedLocation_.nameEn, flags: 1);

    return queryBuilder.build().find();
  }

  /// Return TRUE if location saved in database.
  static bool isAdded(Database db, {required String locationKey}) {
    // Get SavedLocationBox.
    final box = db.store.box<SavedLocation>();
    // Create search query.
    final Query<SavedLocation> query = box.query(SavedLocation_.locationKey.equals(locationKey)).build();
    // Check search result is not empty.
    return query.find().isNotEmpty;
  }

  /// Add new location object to database.
  void put(Database db) => db.store.box<SavedLocation>().put(this);

  /// Update SavedLocation.
  void update(Database db) => db.store.box<SavedLocation>().put(this);

  /// Remove SavedLocation from database.
  void remove(Database db) {
    db.store.box<SavedLocation>().remove(id);
    if(isPinned) {
      if(!isCollectionEmpty(db)) {
        getAll(db)[0].pin(db);
      }
    }
  }

  /// Pin SavedLocation.
  void pin(Database db) {
    // Get SavedLocation box.
    final box = db.store.box<SavedLocation>();
    // Create search query.
    final Query<SavedLocation> query = box.query(SavedLocation_.isPinned.equals(true)).build();
    // Find pinned location.
    final List<SavedLocation> queryResult = query.find();
    // Check search result length.
    if (queryResult.isNotEmpty) {
      // Unpin it.
      box.put(queryResult.first.apply(isPinned: false));
    }
    // Pin new location.
    box.put(apply(isPinned: true));
    // Close query.
    query.close();
  }
}