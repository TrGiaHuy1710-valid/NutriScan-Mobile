import '../../../../core/persistence/app_database.dart';
import '../../domain/entities/user_health_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../mock_profile_data.dart';

class SqliteProfileRepository implements ProfileRepository {
  SqliteProfileRepository(this._database);

  final AppDatabase _database;

  @override
  Future<UserHealthProfile> getProfile() async {
    final db = await _database.database;
    final rows = await db.query('user_profiles', where: 'id = ?', whereArgs: [1]);
    if (rows.isEmpty) {
      final defaultProfile = mockUserHealthProfile;
      await db.insert('user_profiles', _profileToMap(defaultProfile));
      return defaultProfile;
    }
    return _profileFromMap(rows.first);
  }

  @override
  Future<void> updateProfile(UserHealthProfile profile) async {
    final db = await _database.database;
    await db.update(
      'user_profiles',
      _profileToMap(profile),
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Map<String, dynamic> _profileToMap(UserHealthProfile profile) {
    return {
      'id': 1,
      'name': profile.name,
      'weight': profile.weight,
      'height': profile.height,
      'age': profile.age,
      'health_goal': profile.healthGoal,
      'dietary_restrictions': profile.dietaryRestrictions,
      'target_calories': profile.targetCalories,
      'target_protein': profile.targetProtein,
      'target_carbs': profile.targetCarbs,
      'target_fat': profile.targetFat,
    };
  }

  UserHealthProfile _profileFromMap(Map<String, dynamic> map) {
    return UserHealthProfile(
      name: map['name'] as String,
      weight: (map['weight'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      age: map['age'] as int,
      healthGoal: map['health_goal'] as String,
      dietaryRestrictions: map['dietary_restrictions'] as String,
      targetCalories: map['target_calories'] as int,
      targetProtein: map['target_protein'] as int,
      targetCarbs: map['target_carbs'] as int,
      targetFat: map['target_fat'] as int,
    );
  }
}
