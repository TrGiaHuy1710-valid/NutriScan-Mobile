import '../../domain/bought_food_item.dart';

enum FoodDiscoverStatus { initial, loading, loaded, failure }

class FoodDiscoverState {
  const FoodDiscoverState({
    required this.status,
    required this.boughtToday,
    this.errorMessage,
  });

  factory FoodDiscoverState.initial() {
    return const FoodDiscoverState(
      status: FoodDiscoverStatus.initial,
      boughtToday: [],
    );
  }

  final FoodDiscoverStatus status;
  final List<BoughtFoodItem> boughtToday;
  final String? errorMessage;

  FoodDiscoverState copyWith({
    FoodDiscoverStatus? status,
    List<BoughtFoodItem>? boughtToday,
    String? errorMessage,
  }) {
    return FoodDiscoverState(
      status: status ?? this.status,
      boughtToday: boughtToday ?? this.boughtToday,
      errorMessage: errorMessage,
    );
  }
}
