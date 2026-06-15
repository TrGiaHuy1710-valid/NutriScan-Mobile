import 'meal_log.dart';

class NutritionSummary {
  const NutritionSummary({
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.mealCount,
  });

  factory NutritionSummary.empty() {
    return NutritionSummary(
      date: DateTime.now(),
      totalCalories: 0,
      totalProtein: 0,
      totalCarbs: 0,
      totalFat: 0,
      mealCount: 0,
    );
  }

  factory NutritionSummary.fromMeals(List<MealLog> meals) {
    return NutritionSummary(
      date: DateTime.now(),
      totalCalories: meals.fold(0, (sum, meal) => sum + meal.calories),
      totalProtein: meals.fold(0, (sum, meal) => sum + meal.protein),
      totalCarbs: meals.fold(0, (sum, meal) => sum + meal.carbs),
      totalFat: meals.fold(0, (sum, meal) => sum + meal.fat),
      mealCount: meals.length,
    );
  }

  final DateTime date;
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFat;
  final int mealCount;
}
