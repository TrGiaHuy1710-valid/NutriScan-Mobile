import '../../nutrition/application/usecases/add_meal_log_usecase.dart';
import '../../nutrition/domain/entities/meal_log.dart';

class ScanMealSuggestion {
  const ScanMealSuggestion({
    required this.mealType,
    required this.foodName,
    required this.portion,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.tags = const [],
  });

  final MealType mealType;
  final String foodName;
  final String portion;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final List<String> tags;

  AddMealLogParams toAddMealParams() {
    return AddMealLogParams(
      mealType: mealType,
      foodName: foodName,
      portion: portion,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      tags: tags,
    );
  }
}
