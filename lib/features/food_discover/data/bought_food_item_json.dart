import '../domain/bought_food_item.dart';

extension BoughtFoodItemJson on BoughtFoodItem {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'source': source,
      'quantityLabel': quantityLabel,
      'addedAt': addedAt.toIso8601String(),
      'canAddAsMeal': canAddAsMeal,
      'tags': tags,
    };
  }
}

BoughtFoodItem boughtFoodItemFromJson(Map<String, dynamic> json) {
  return BoughtFoodItem(
    id: json['id'] as String? ?? 'bought_local',
    productId: json['productId'] as String?,
    productName: json['productName'] as String? ?? 'Saved food',
    source: json['source'] as String? ?? 'local',
    quantityLabel: json['quantityLabel'] as String? ?? '1 item',
    addedAt:
        DateTime.tryParse(json['addedAt'] as String? ?? '') ?? DateTime.now(),
    canAddAsMeal: json['canAddAsMeal'] as bool? ?? false,
    tags: (json['tags'] as List?)?.whereType<String>().toList() ?? const [],
  );
}
