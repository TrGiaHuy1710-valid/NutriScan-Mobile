import '../../domain/entities/meal_log.dart';
import '../../domain/repositories/nutrition_repository.dart';

class AddMealLogParams {
  const AddMealLogParams({
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
}

class AddMealLogUseCase {
  const AddMealLogUseCase(this.repository);

  final NutritionRepository repository;

  Future<MealLog> call(AddMealLogParams params) {
    return repository.addMealLog(
      mealType: params.mealType,
      foodName: params.foodName,
      portion: params.portion,
      calories: params.calories,
      protein: params.protein,
      carbs: params.carbs,
      fat: params.fat,
      tags: params.tags,
    );
  }
}
