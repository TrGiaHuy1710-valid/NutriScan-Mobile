import '../../../../core/persistence/app_database.dart';
import '../../domain/entities/meal_log.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../mock_nutrition_data.dart';

class SqliteNutritionRepository implements NutritionRepository {
  SqliteNutritionRepository(this._database);

  final AppDatabase _database;
  bool _hasSeeded = false;

  @override
  Future<List<MealLog>> getTodayMeals() async {
    await _seedIfEmpty();
    final db = await _database.database;
    final rows = await db.query('meal_logs', orderBy: 'created_at DESC');
    return rows.map(_mealFromRow).toList();
  }

  @override
  Future<MealLog> addMealLog({
    required MealType mealType,
    required String foodName,
    required String portion,
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
    List<String> tags = const [],
  }) async {
    await _seedIfEmpty();
    final meal = MealLog(
      id: 'meal_${DateTime.now().millisecondsSinceEpoch}',
      mealType: mealType,
      foodName: foodName,
      portion: portion,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      createdAt: DateTime.now(),
      tags: tags,
    );

    final db = await _database.database;
    await db.insert('meal_logs', _mealToRow(meal));
    return meal;
  }

  Future<void> _seedIfEmpty() async {
    if (_hasSeeded) {
      return;
    }

    final db = await _database.database;
    final count = await db.rawQuery('SELECT COUNT(*) AS count FROM meal_logs');
    final existingCount = count.first['count'] as int? ?? 0;
    if (existingCount == 0) {
      for (final meal in mockMealLogs) {
        await db.insert('meal_logs', _mealToRow(meal));
      }
    }
    _hasSeeded = true;
  }

  Map<String, Object?> _mealToRow(MealLog meal) {
    return {
      'id': meal.id,
      'meal_type': meal.mealType.name,
      'food_name': meal.foodName,
      'portion': meal.portion,
      'calories': meal.calories,
      'protein': meal.protein,
      'carbs': meal.carbs,
      'fat': meal.fat,
      'created_at': meal.createdAt.toIso8601String(),
      'tags': meal.tags.join(','),
    };
  }

  MealLog _mealFromRow(Map<String, Object?> row) {
    return MealLog(
      id: row['id'] as String,
      mealType: MealType.values.firstWhere(
        (type) => type.name == row['meal_type'],
        orElse: () => MealType.snack,
      ),
      foodName: row['food_name'] as String,
      portion: row['portion'] as String,
      calories: row['calories'] as int,
      protein: row['protein'] as int,
      carbs: row['carbs'] as int,
      fat: row['fat'] as int,
      createdAt: DateTime.parse(row['created_at'] as String),
      tags: ((row['tags'] as String?) ?? '')
          .split(',')
          .where((tag) => tag.isNotEmpty)
          .toList(),
    );
  }
}
