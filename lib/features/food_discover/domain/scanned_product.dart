import '../../food_scan/domain/ingredient_insight.dart';

class ScannedProduct {
  const ScannedProduct({
    required this.id,
    required this.productName,
    required this.source,
    required this.quantityLabel,
    required this.scannedAt,
    required this.isMealLike,
    this.brandName,
    this.barcode,
    this.ingredients = const [],
    this.insights = const [],
    this.tags = const [],
    this.confidenceLabel = 'Mock result',
  });

  final String id;
  final String productName;
  final String source;
  final String quantityLabel;
  final DateTime scannedAt;
  final bool isMealLike;
  final String? brandName;
  final String? barcode;
  final List<String> ingredients;
  final List<IngredientInsight> insights;
  final List<String> tags;
  final String confidenceLabel;
}
