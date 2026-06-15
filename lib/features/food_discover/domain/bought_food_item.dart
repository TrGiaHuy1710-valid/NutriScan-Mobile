class BoughtFoodItem {
  const BoughtFoodItem({
    required this.id,
    required this.productName,
    required this.source,
    required this.quantityLabel,
    required this.addedAt,
    required this.canAddAsMeal,
    this.productId,
    this.tags = const [],
  });

  final String id;
  final String productName;
  final String source;
  final String quantityLabel;
  final DateTime addedAt;
  final bool canAddAsMeal;
  final String? productId;
  final List<String> tags;
}
