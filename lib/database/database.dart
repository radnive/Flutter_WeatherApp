import '../objectbox.g.dart';

class _ObjectBox {
  late final Store store;
  _ObjectBox._create(this.store);

  static Future<_ObjectBox> create() async {
    final store = await openStore();
    return _ObjectBox._create(store);
  }
}

class Database {
  // Make database class singleton.
  static final Database _connector = Database._internal();
  factory Database() => _connector;
  Database._internal();

  // Connect to objectBox.
  late _ObjectBox _objectBox;
  Future<void> create() async => _objectBox = await _ObjectBox.create();
  Store get store => _objectBox.store;
}