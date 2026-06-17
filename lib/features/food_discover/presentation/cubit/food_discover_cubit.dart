import 'package:flutter/foundation.dart';

import '../../application/usecases/get_bought_today_usecase.dart';
import '../../application/usecases/save_bought_today_usecase.dart';
import '../../domain/bought_food_item.dart';
import 'food_discover_state.dart';

class FoodDiscoverCubit extends ChangeNotifier {
  FoodDiscoverCubit({
    required GetBoughtTodayUseCase getBoughtTodayUseCase,
    required SaveBoughtTodayUseCase saveBoughtTodayUseCase,
  }) : _getBoughtTodayUseCase = getBoughtTodayUseCase,
       _saveBoughtTodayUseCase = saveBoughtTodayUseCase;

  final GetBoughtTodayUseCase _getBoughtTodayUseCase;
  final SaveBoughtTodayUseCase _saveBoughtTodayUseCase;

  FoodDiscoverState _state = FoodDiscoverState.initial();

  FoodDiscoverState get state => _state;

  Future<void> loadBoughtToday() async {
    _emit(_state.copyWith(status: FoodDiscoverStatus.loading));
    try {
      final items = await _getBoughtTodayUseCase();
      _emit(
        FoodDiscoverState(
          status: FoodDiscoverStatus.loaded,
          boughtToday: items,
        ),
      );
    } catch (_) {
      _emit(
        _state.copyWith(
          status: FoodDiscoverStatus.failure,
          errorMessage: 'Unable to load bought-today foods.',
        ),
      );
    }
  }

  Future<void> upsertBoughtFood(BoughtFoodItem item) async {
    final items = List<BoughtFoodItem>.from(_state.boughtToday)
      ..removeWhere((existing) => existing.productId == item.productId)
      ..insert(0, item);

    try {
      await _saveBoughtTodayUseCase(items);
      _emit(
        FoodDiscoverState(
          status: FoodDiscoverStatus.loaded,
          boughtToday: items,
        ),
      );
    } catch (_) {
      _emit(
        _state.copyWith(
          status: FoodDiscoverStatus.failure,
          errorMessage: 'Unable to save bought-today food.',
        ),
      );
    }
  }

  Future<void> deleteBoughtFood(String id) async {
    final items = List<BoughtFoodItem>.from(_state.boughtToday)
      ..removeWhere((existing) => existing.id == id);

    try {
      await _saveBoughtTodayUseCase(items);
      _emit(
        FoodDiscoverState(
          status: FoodDiscoverStatus.loaded,
          boughtToday: items,
        ),
      );
    } catch (_) {
      _emit(
        _state.copyWith(
          status: FoodDiscoverStatus.failure,
          errorMessage: 'Unable to delete bought-today food.',
        ),
      );
    }
  }

  Future<void> clearBoughtFoods() async {
    try {
      await _saveBoughtTodayUseCase(const []);
      _emit(
        const FoodDiscoverState(
          status: FoodDiscoverStatus.loaded,
          boughtToday: [],
        ),
      );
    } catch (_) {
      _emit(
        _state.copyWith(
          status: FoodDiscoverStatus.failure,
          errorMessage: 'Unable to clear bought-today foods.',
        ),
      );
    }
  }

  void _emit(FoodDiscoverState state) {
    _state = state;
    notifyListeners();
  }
}
