import '../../domain/entities/meal_log.dart';
import '../../domain/repositories/nutrition_repository.dart';

class GetTodayMealsUseCase {
  const GetTodayMealsUseCase(this._repository);

  final NutritionRepository _repository;

  Future<List<MealLog>> call() {
    return _repository.getTodayMeals();
  }
}
