import '../../domain/entities/meal_log.dart';
import '../../domain/entities/nutrition_summary.dart';

class CalculateTodayNutritionUseCase {
  const CalculateTodayNutritionUseCase();

  NutritionSummary call(List<MealLog> meals) {
    return NutritionSummary.fromMeals(meals);
  }
}
