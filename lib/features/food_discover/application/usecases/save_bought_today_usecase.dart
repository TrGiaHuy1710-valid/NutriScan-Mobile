import '../../domain/bought_food_item.dart';
import '../../domain/repositories/food_discover_repository.dart';

class SaveBoughtTodayUseCase {
  const SaveBoughtTodayUseCase(this._repository);

  final FoodDiscoverRepository _repository;

  Future<void> call(List<BoughtFoodItem> items) {
    return _repository.saveBoughtToday(items);
  }
}
