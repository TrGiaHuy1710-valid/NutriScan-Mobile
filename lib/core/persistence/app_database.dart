import 'package:path/path.dart' as p;
import 'package:sqflite_common/sqlite_api.dart';

import 'database_factory_provider.dart';

class AppDatabase {
  AppDatabase({this.path});

  AppDatabase.inMemory() : path = inMemoryDatabasePath;

  static const fixedLocalUserId = 'user_demo_huy';
  static const fixedLocalEmail = 'huy@example.com';
  static const fixedLocalDisplayName = 'Huy Nguyen';
  static const fixedLocalPassword = 'demo123';
  static const fixedLocalPasswordToken = 'aHV5QGV4YW1wbGUuY29tOmRlbW8xMjM=';

  final String? path;
  Database? _database;
  DatabaseFactory? _databaseFactory;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) {
      await _ensureSchema(existing);
      await _seedFixedLocalAccount(existing);
      return existing;
    }

    final factory = await _resolveFactory();
    final databasePath = path ?? await _defaultPath();
    final database = await factory.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, version) async {
          await _ensureSchema(db);
          await _seedFixedLocalAccount(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          await _ensureSchema(db);
          await _seedFixedLocalAccount(db);
        },
        onOpen: (db) async {
          await _ensureSchema(db);
          await _seedFixedLocalAccount(db);
        },
      ),
    );

    _database = database;
    return database;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<String> _defaultPath() async {
    final factory = await _resolveFactory();
    final databasesPath = await resolveDatabasesPath(factory);
    return p.join(databasesPath, 'healtrack_daily.sqlite');
  }

  Future<DatabaseFactory> _resolveFactory() async {
    final existing = _databaseFactory;
    if (existing != null) {
      return existing;
    }

    final factory = await resolveDatabaseFactory();
    _databaseFactory = factory;
    return factory;
  }

  Future<void> _ensureSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS meal_logs (
        id TEXT PRIMARY KEY,
        meal_type TEXT NOT NULL,
        food_name TEXT NOT NULL,
        portion TEXT NOT NULL,
        calories INTEGER NOT NULL,
        protein INTEGER NOT NULL,
        carbs INTEGER NOT NULL,
        fat INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        tags TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS bought_food_items (
        id TEXT PRIMARY KEY,
        product_id TEXT,
        product_name TEXT NOT NULL,
        source TEXT NOT NULL,
        quantity_label TEXT NOT NULL,
        added_at TEXT NOT NULL,
        can_add_as_meal INTEGER NOT NULL,
        tags TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS scheduled_workout (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        difficulty TEXT NOT NULL,
        equipment TEXT NOT NULL,
        exercises TEXT NOT NULL,
        estimated_calories_burned INTEGER NOT NULL,
        tags TEXT NOT NULL,
        is_scheduled INTEGER NOT NULL,
        is_completed INTEGER NOT NULL,
        scheduled_start_time TEXT,
        scheduled_end_time TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS auth_users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        display_name TEXT NOT NULL,
        mock_password_token TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS auth_session (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        user_id TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_profiles (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        name TEXT NOT NULL,
        weight REAL NOT NULL,
        height REAL NOT NULL,
        age INTEGER NOT NULL,
        health_goal TEXT NOT NULL,
        dietary_restrictions TEXT NOT NULL,
        target_calories INTEGER NOT NULL,
        target_protein INTEGER NOT NULL,
        target_carbs INTEGER NOT NULL,
        target_fat INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _seedFixedLocalAccount(Database db) async {
    final existingRows = await db.query(
      'auth_users',
      where: 'email = ?',
      whereArgs: [fixedLocalEmail],
      limit: 1,
    );

    if (existingRows.isEmpty) {
      await db.insert('auth_users', {
        'id': fixedLocalUserId,
        'email': fixedLocalEmail,
        'display_name': fixedLocalDisplayName,
        'mock_password_token': fixedLocalPasswordToken,
        'created_at': DateTime(2026, 6, 14).toIso8601String(),
      });
    } else {
      await db.update(
        'auth_users',
        {
          'display_name': fixedLocalDisplayName,
          'mock_password_token': fixedLocalPasswordToken,
        },
        where: 'email = ?',
        whereArgs: [fixedLocalEmail],
      );
    }

    final existingProfile = await db.query(
      'user_profiles',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (existingProfile.isEmpty) {
      await db.insert('user_profiles', {
        'id': 1,
        'name': 'Huy Nguyễn',
        'weight': 60.0,
        'height': 165.0,
        'age': 22,
        'health_goal': 'Giữ cân',
        'dietary_restrictions': 'Shellfish',
        'target_calories': 2000,
        'target_protein': 120,
        'target_carbs': 230,
        'target_fat': 67,
      });
    }
  }
}
