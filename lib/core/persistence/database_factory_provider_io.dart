import 'dart:io';

import 'package:sqflite/sqflite.dart' as mobile_sqflite;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

bool _hasInitializedFfi = false;

Future<DatabaseFactory> resolveDatabaseFactoryForPlatform() async {
  if (Platform.isAndroid || Platform.isIOS) {
    return mobile_sqflite.databaseFactory;
  }

  if (!_hasInitializedFfi) {
    ffi.sqfliteFfiInit();
    _hasInitializedFfi = true;
  }
  return ffi.databaseFactoryFfi;
}

Future<String> resolveDatabasesPathForPlatform(DatabaseFactory factory) async {
  if (Platform.isAndroid || Platform.isIOS) {
    return mobile_sqflite.getDatabasesPath();
  }
  return factory.getDatabasesPath();
}
