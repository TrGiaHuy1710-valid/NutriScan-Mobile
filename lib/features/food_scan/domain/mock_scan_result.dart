import 'ingredient_insight.dart';
import 'scan_meal_suggestion.dart';

class MockScanResult {
  const MockScanResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.source,
    required this.mealSuggestion,
    this.ingredients = const [],
    this.insights = const [],
    this.barcode,
    this.brandName,
    this.isMealLike = true,
    this.tags = const [],
    this.confidenceLabel = 'Mock result',
  });

  final String id;
  final String title;
  final String subtitle;
  final String badge;
  final String source;
  final ScanMealSuggestion mealSuggestion;
  final List<String> ingredients;
  final List<IngredientInsight> insights;
  final String? barcode;
  final String? brandName;
  final bool isMealLike;
  final List<String> tags;
  final String confidenceLabel;
}
