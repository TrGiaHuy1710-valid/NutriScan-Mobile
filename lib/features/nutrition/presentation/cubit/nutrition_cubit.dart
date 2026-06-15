import 'package:flutter/foundation.dart';

import '../../application/usecases/add_meal_log_usecase.dart';
import '../../application/usecases/calculate_today_nutrition_usecase.dart';
import '../../application/usecases/get_today_meals_usecase.dart';
import 'nutrition_state.dart';

class NutritionCubit extends ChangeNotifier {
  NutritionCubit({
    required AddMealLogUseCase addMealLogUseCase,
    required GetTodayMealsUseCase getTodayMealsUseCase,
    required CalculateTodayNutritionUseCase calculateTodayNutritionUseCase,
  }) : _addMealLogUseCase = addMealLogUseCase,
       _getTodayMealsUseCase = getTodayMealsUseCase,
       _calculateTodayNutritionUseCase = calculateTodayNutritionUseCase;

  final AddMealLogUseCase _addMealLogUseCase;
  final GetTodayMealsUseCase _getTodayMealsUseCase;
  final CalculateTodayNutritionUseCase _calculateTodayNutritionUseCase;

  NutritionState _state = NutritionState.initial();

  NutritionState get state => _state;

  Future<void> loadTodayNutrition() async {
    _emit(_state.copyWith(status: NutritionStatus.loading));

    try {
      final meals = await _getTodayMealsUseCase();
      _emit(
        NutritionState(
          status: NutritionStatus.loaded,
          meals: meals,
          summary: _calculateTodayNutritionUseCase(meals),
        ),
      );
    } catch (_) {
      _emit(
        _state.copyWith(
          status: NutritionStatus.failure,
          errorMessage: 'Unable to load meals right now.',
        ),
      );
    }
  }

  Future<void> addMeal(AddMealLogParams params) async {
    try {
      await _addMealLogUseCase(params);
      final meals = await _getTodayMealsUseCase();
      _emit(
        NutritionState(
          status: NutritionStatus.loaded,
          meals: meals,
          summary: _calculateTodayNutritionUseCase(meals),
        ),
      );
    } catch (_) {
      _emit(
        _state.copyWith(
          status: NutritionStatus.failure,
          errorMessage: 'Unable to save this meal right now.',
        ),
      );
    }
  }

  void _emit(NutritionState state) {
    _state = state;
    notifyListeners();
  }
}
