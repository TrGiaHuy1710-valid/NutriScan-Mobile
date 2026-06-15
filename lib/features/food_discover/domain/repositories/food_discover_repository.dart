import '../bought_food_item.dart';

abstract class FoodDiscoverRepository {
  Future<List<BoughtFoodItem>> getBoughtToday();

  Future<void> saveBoughtToday(List<BoughtFoodItem> items);
}
