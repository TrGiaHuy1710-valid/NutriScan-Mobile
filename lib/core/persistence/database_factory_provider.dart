import 'database_factory_provider_io.dart'
    if (dart.library.html) 'database_factory_provider_web.dart';
import 'package:sqflite_common/sqlite_api.dart';

Future<DatabaseFactory> resolveDatabaseFactory() {
  return resolveDatabaseFactoryForPlatform();
}

Future<String> resolveDatabasesPath(DatabaseFactory factory) {
  return resolveDatabasesPathForPlatform(factory);
}
