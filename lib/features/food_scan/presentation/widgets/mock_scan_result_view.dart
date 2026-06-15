import 'package:flutter/material.dart';

import '../../../dashboard/presentation/widgets/section_card.dart';
import '../../domain/mock_scan_result.dart';

class MockScanResultView extends StatelessWidget {
  const MockScanResultView({
    required this.result,
    required this.onConfirmProduct,
    required this.onSaveMeal,
    super.key,
  });

  final MockScanResult result;
  final Future<void> Function() onConfirmProduct;
  final Future<void> Function() onSaveMeal;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Chip(label: Text(result.badge)),
              const SizedBox(height: 8),
              Text(
                result.title,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(result.subtitle),
              if (result.brandName != null) ...[
                const SizedBox(height: 8),
                Text('Brand: ${result.brandName}'),
              ],
              if (result.barcode != null) ...[
                const SizedBox(height: 12),
                Text('Barcode: ${result.barcode}'),
              ],
              const SizedBox(height: 12),
              Text(result.confidenceLabel),
              if (result.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: result.tags
                      .map((tag) => Chip(label: Text(tag)))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estimated meal', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(result.mealSuggestion.foodName),
              Text(
                '${result.mealSuggestion.calories} cal - '
                '${result.mealSuggestion.protein}g protein - '
                '${result.mealSuggestion.carbs}g carbs - '
                '${result.mealSuggestion.fat}g fat',
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('confirmMockScanProductButton'),
                  onPressed: onConfirmProduct,
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('Add to Bought Today'),
                ),
              ),
              if (result.isMealLike) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    key: const Key('saveMockScanMealButton'),
                    onPressed: onSaveMeal,
                    icon: const Icon(Icons.check),
                    label: const Text('Add as Meal'),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (result.ingredients.isNotEmpty) ...[
          const SizedBox(height: 12),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ingredients', style: textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: result.ingredients
                      .map((ingredient) => Chip(label: Text(ingredient)))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
        if (result.insights.isNotEmpty) ...[
          const SizedBox(height: 12),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Insights', style: textTheme.titleMedium),
                const SizedBox(height: 8),
                ...result.insights.map(
                  (insight) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.info_outline),
                    title: Text('${insight.type} - ${insight.level}'),
                    subtitle: Text(insight.message),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
