import 'dart:convert';

import 'package:sqflite_common/sqlite_api.dart';

import '../../../../core/persistence/app_database.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class SqliteAuthRepository implements AuthRepository {
  SqliteAuthRepository(this._database);

  final AppDatabase _database;

  @override
  Future<AuthUser?> getCurrentUser() async {
    final db = await _database.database;
    final sessionRows = await db.query('auth_session', limit: 1);
    if (sessionRows.isEmpty) {
      return null;
    }

    final userId = sessionRows.first['user_id'] as String;
    final userRows = await db.query(
      'auth_users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (userRows.isEmpty) {
      await logout();
      return null;
    }
    return _userFromRow(userRows.first);
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final db = await _database.database;
    if (_isFixedLocalLogin(normalizedEmail, password)) {
      await _repairFixedLocalAccount(db);
    }

    final existingRows = await db.query(
      'auth_users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );

    late final AuthUser user;
    if (existingRows.isEmpty) {
      throw StateError('No local account found. Create an account first.');
    } else {
      final expectedToken = _mockToken(normalizedEmail, password);
      final storedToken = existingRows.first['mock_password_token'] as String?;
      if (storedToken != expectedToken) {
        throw StateError('Invalid local credentials.');
      }
      user = _userFromRow(existingRows.first);
    }

    await db.insert('auth_session', {
      'id': 1,
      'user_id': user.id,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    return user;
  }

  @override
  Future<AuthUser> createAccount({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final safeDisplayName = displayName.trim().isEmpty
        ? 'HealTrack User'
        : displayName.trim();
    final db = await _database.database;
    final existingRows = await db.query(
      'auth_users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );

    if (existingRows.isNotEmpty) {
      throw StateError('This local account already exists. Use login.');
    }

    final user = AuthUser(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: normalizedEmail,
      displayName: safeDisplayName,
    );
    await db.insert('auth_users', {
      'id': user.id,
      'email': user.email,
      'display_name': user.displayName,
      'mock_password_token': _mockToken(normalizedEmail, password),
      'created_at': DateTime.now().toIso8601String(),
    });
    await db.insert('auth_session', {
      'id': 1,
      'user_id': user.id,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return user;
  }

  @override
  Future<void> logout() async {
    final db = await _database.database;
    await db.delete('auth_session');
  }

  AuthUser _userFromRow(Map<String, Object?> row) {
    return AuthUser(
      id: row['id'] as String,
      email: row['email'] as String,
      displayName: row['display_name'] as String,
    );
  }

  String _mockToken(String email, String password) {
    return base64Encode(utf8.encode('$email:$password'));
  }

  bool _isFixedLocalLogin(String email, String password) {
    return email == AppDatabase.fixedLocalEmail &&
        password == AppDatabase.fixedLocalPassword;
  }

  Future<void> _repairFixedLocalAccount(Database db) async {
    final existingRows = await db.query(
      'auth_users',
      where: 'email = ?',
      whereArgs: [AppDatabase.fixedLocalEmail],
      limit: 1,
    );

    if (existingRows.isEmpty) {
      await db.insert('auth_users', {
        'id': AppDatabase.fixedLocalUserId,
        'email': AppDatabase.fixedLocalEmail,
        'display_name': AppDatabase.fixedLocalDisplayName,
        'mock_password_token': AppDatabase.fixedLocalPasswordToken,
        'created_at': DateTime(2026, 6, 14).toIso8601String(),
      });
      return;
    }

    await db.update(
      'auth_users',
      {
        'display_name': AppDatabase.fixedLocalDisplayName,
        'mock_password_token': AppDatabase.fixedLocalPasswordToken,
      },
      where: 'email = ?',
      whereArgs: [AppDatabase.fixedLocalEmail],
    );
  }
}
