import '../entities/meal_log.dart';

abstract class NutritionRepository {
  Future<List<MealLog>> getTodayMeals();

  Future<MealLog> addMealLog({
    required MealType mealType,
    required String foodName,
    required String portion,
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
    List<String> tags,
  });
}
