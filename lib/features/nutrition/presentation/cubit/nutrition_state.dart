import '../../domain/entities/meal_log.dart';
import '../../domain/entities/nutrition_summary.dart';

enum NutritionStatus { initial, loading, loaded, failure }

class NutritionState {
  const NutritionState({
    required this.status,
    required this.meals,
    required this.summary,
    this.errorMessage,
  });

  factory NutritionState.initial() {
    return NutritionState(
      status: NutritionStatus.initial,
      meals: const [],
      summary: NutritionSummary.empty(),
    );
  }

  final NutritionStatus status;
  final List<MealLog> meals;
  final NutritionSummary summary;
  final String? errorMessage;

  NutritionState copyWith({
    NutritionStatus? status,
    List<MealLog>? meals,
    NutritionSummary? summary,
    String? errorMessage,
  }) {
    return NutritionState(
      status: status ?? this.status,
      meals: meals ?? this.meals,
      summary: summary ?? this.summary,
      errorMessage: errorMessage,
    );
  }
}
