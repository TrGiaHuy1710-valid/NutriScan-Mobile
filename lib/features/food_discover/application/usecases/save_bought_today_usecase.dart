import '../../domain/bought_food_item.dart';
import '../../domain/repositories/food_discover_repository.dart';

class SaveBoughtTodayUseCase {
  const SaveBoughtTodayUseCase(this.repository);

  final FoodDiscoverRepository repository;

  Future<void> call(List<BoughtFoodItem> items) {
    return repository.saveBoughtToday(items);
  }
}
