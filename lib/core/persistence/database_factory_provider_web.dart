import 'package:sqflite_common/sqlite_api.dart';

Future<DatabaseFactory> resolveDatabaseFactoryForPlatform() {
  throw UnsupportedError('Local SQLite is not supported on web yet.');
}

Future<String> resolveDatabasesPathForPlatform(DatabaseFactory factory) {
  throw UnsupportedError('Local SQLite is not supported on web yet.');
}
