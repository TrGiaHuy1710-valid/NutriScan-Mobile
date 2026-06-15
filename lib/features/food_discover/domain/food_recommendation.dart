import '../../nutrition/application/usecases/add_meal_log_usecase.dart';

class FoodRecommendation {
  const FoodRecommendation({
    required this.id,
    required this.section,
    required this.title,
    required this.description,
    required this.tags,
    this.mealSuggestion,
  });

  final String id;
  final String section;
  final String title;
  final String description;
  final List<String> tags;
  final AddMealLogParams? mealSuggestion;
}
