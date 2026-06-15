import 'package:flutter/material.dart';

import '../../../dashboard/presentation/widgets/section_card.dart';
import '../../../nutrition/application/usecases/add_meal_log_usecase.dart';
import '../../domain/bought_food_item.dart';
import '../../domain/food_recommendation.dart';
import '../../domain/scanned_product.dart';
import '../widgets/food_discover_cards.dart';

class FoodsDiscoverPage extends StatelessWidget {
  const FoodsDiscoverPage({
    required this.recentlyScannedProducts,
    required this.boughtToday,
    required this.recommendations,
    required this.activeTags,
    required this.recommendationReason,
    required this.onAddRecommendedMeal,
    super.key,
  });

  final List<ScannedProduct> recentlyScannedProducts;
  final List<BoughtFoodItem> boughtToday;
  final List<FoodRecommendation> recommendations;
  final List<String> activeTags;
  final String recommendationReason;
  final Future<void> Function(AddMealLogParams params) onAddRecommendedMeal;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Foods')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Discover foods',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text('Simple ideas for balanced meals and steady energy.'),
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Based on your day', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(recommendationReason),
                  if (activeTags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: activeTags.take(8).map((tag) {
                        return Chip(label: Text(tag));
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...recommendations.map(
              (recommendation) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RecommendationCard(
                  recommendation: recommendation,
                  onAddToPlan: recommendation.mealSuggestion == null
                      ? null
                      : () => onAddRecommendedMeal(
                          recommendation.mealSuggestion!,
                        ),
                ),
              ),
            ),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Products you scanned', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (recentlyScannedProducts.isEmpty)
                    const Text('No confirmed scans yet.')
                  else
                    ...recentlyScannedProducts.map(
                      (product) => ScannedProductTile(product: product),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bought today', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (boughtToday.isEmpty)
                    const Text('Nothing added yet.')
                  else
                    ...boughtToday.map(
                      (item) => BoughtFoodItemTile(item: item),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suggested simple ingredients',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Eggs, tofu, beans, fruit, milk, nuts, rice, and vegetables are easy everyday options for home cooking.',
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      Chip(label: Text('home_cooking')),
                      Chip(label: Text('balanced')),
                      Chip(label: Text('high_protein')),
                      Chip(label: Text('light')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
