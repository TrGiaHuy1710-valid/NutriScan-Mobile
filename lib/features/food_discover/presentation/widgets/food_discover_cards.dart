import 'package:flutter/material.dart';

import '../../../dashboard/presentation/widgets/section_card.dart';
import '../../domain/bought_food_item.dart';
import '../../domain/food_recommendation.dart';
import '../../domain/scanned_product.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    required this.recommendation,
    required this.onAddToPlan,
    super.key,
  });

  final FoodRecommendation recommendation;
  final VoidCallback? onAddToPlan;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recommendation.section,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            recommendation.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(recommendation.description),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recommendation.tags
                .map((tag) => Chip(label: Text(tag)))
                .toList(),
          ),
          if (recommendation.mealSuggestion != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: onAddToPlan,
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text('Add to plan'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ScannedProductTile extends StatelessWidget {
  const ScannedProductTile({required this.product, super.key});

  final ScannedProduct product;

  @override
  Widget build(BuildContext context) {
    final details = [
      if (product.brandName != null) product.brandName!,
      product.source,
      product.quantityLabel,
      product.confidenceLabel,
    ].join(' - ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.document_scanner_outlined),
        title: Text(product.productName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(details),
            if (product.tags.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: product.tags
                    .map((tag) => Chip(label: Text(tag)))
                    .toList(),
              ),
            ],
          ],
        ),
        trailing: product.isMealLike ? const Text('Meal-like') : null,
      ),
    );
  }
}

class BoughtFoodItemTile extends StatelessWidget {
  const BoughtFoodItemTile({required this.item, super.key});

  final BoughtFoodItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.check_circle_outline),
        title: Text(item.productName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item.quantityLabel} - ${item.source}'),
            if (item.tags.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: item.tags
                    .map((tag) => Chip(label: Text(tag)))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
