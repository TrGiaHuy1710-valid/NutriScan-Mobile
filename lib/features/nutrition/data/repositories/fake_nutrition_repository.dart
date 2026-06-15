import '../../../../core/persistence/local_json_store.dart';
import '../../domain/entities/meal_log.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../meal_log_json.dart';
import '../mock_nutrition_data.dart';

class FakeNutritionRepository implements NutritionRepository {
  FakeNutritionRepository({LocalJsonStore? store, List<MealLog>? initialMeals})
    : _store = store,
      _initialMeals = initialMeals ?? mockMealLogs,
      _meals = [];

  static const _storageKey = 'mealLogs';

  final LocalJsonStore? _store;
  final List<MealLog> _initialMeals;
  final List<MealLog> _meals;
  bool _hasLoaded = false;

  @override
  Future<List<MealLog>> getTodayMeals() async {
    await _ensureLoaded();
    return List<MealLog>.unmodifiable(_meals);
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
    await _ensureLoaded();
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

    _meals.insert(0, meal);
    await _persist();
    return meal;
  }

  Future<void> _ensureLoaded() async {
    if (_hasLoaded) {
      return;
    }

    final storedMeals = await _store?.readList(_storageKey);
    if (storedMeals == null) {
      _meals
        ..clear()
        ..addAll(_initialMeals);
    } else {
      _meals
        ..clear()
        ..addAll(storedMeals.map(mealLogFromJson));
    }
    _hasLoaded = true;
  }

  Future<void> _persist() async {
    await _store?.writeList(
      _storageKey,
      _meals.map((meal) => meal.toJson()).toList(),
    );
  }
}
