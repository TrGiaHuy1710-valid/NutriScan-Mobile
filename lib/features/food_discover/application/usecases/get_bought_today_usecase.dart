import '../../domain/bought_food_item.dart';
import '../../domain/repositories/food_discover_repository.dart';

class GetBoughtTodayUseCase {
  const GetBoughtTodayUseCase(this._repository);

  final FoodDiscoverRepository _repository;

  Future<List<BoughtFoodItem>> call() {
    return _repository.getBoughtToday();
  }
}
