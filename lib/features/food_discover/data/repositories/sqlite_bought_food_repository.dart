import '../../../../core/persistence/app_database.dart';
import '../../domain/bought_food_item.dart';
import '../../domain/repositories/food_discover_repository.dart';
import '../mock_food_discover_data.dart';

class SqliteBoughtFoodRepository implements FoodDiscoverRepository {
  SqliteBoughtFoodRepository(this._database);

  final AppDatabase _database;
  bool _hasSeeded = false;

  @override
  Future<List<BoughtFoodItem>> getBoughtToday() async {
    await _seedIfEmpty();
    final db = await _database.database;
    final rows = await db.query('bought_food_items', orderBy: 'added_at DESC');
    return rows.map(_itemFromRow).toList();
  }

  @override
  Future<void> saveBoughtToday(List<BoughtFoodItem> items) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.delete('bought_food_items');
      for (final item in items) {
        await txn.insert('bought_food_items', _itemToRow(item));
      }
    });
  }

  Future<void> _seedIfEmpty() async {
    if (_hasSeeded) {
      return;
    }

    final db = await _database.database;
    final count = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM bought_food_items',
    );
    final existingCount = count.first['count'] as int? ?? 0;
    if (existingCount == 0) {
      for (final item in mockBoughtToday) {
        await db.insert('bought_food_items', _itemToRow(item));
      }
    }
    _hasSeeded = true;
  }

  Map<String, Object?> _itemToRow(BoughtFoodItem item) {
    return {
      'id': item.id,
      'product_id': item.productId,
      'product_name': item.productName,
      'source': item.source,
      'quantity_label': item.quantityLabel,
      'added_at': item.addedAt.toIso8601String(),
      'can_add_as_meal': item.canAddAsMeal ? 1 : 0,
      'tags': item.tags.join(','),
    };
  }

  BoughtFoodItem _itemFromRow(Map<String, Object?> row) {
    return BoughtFoodItem(
      id: row['id'] as String,
      productId: row['product_id'] as String?,
      productName: row['product_name'] as String,
      source: row['source'] as String,
      quantityLabel: row['quantity_label'] as String,
      addedAt: DateTime.parse(row['added_at'] as String),
      canAddAsMeal: row['can_add_as_meal'] == 1,
      tags: ((row['tags'] as String?) ?? '')
          .split(',')
          .where((tag) => tag.isNotEmpty)
          .toList(),
    );
  }
}
