import 'package:flutter/material.dart';

import '../../../food_discover/domain/scanned_product.dart';
import '../../../nutrition/application/usecases/add_meal_log_usecase.dart';
import '../../data/mock_food_scan_data.dart';
import '../../domain/mock_scan_result.dart';
import '../widgets/mock_scan_result_view.dart';

class ScanFoodPage extends StatelessWidget {
  const ScanFoodPage({
    required this.onProductConfirmed,
    required this.onMealSaved,
    super.key,
  });

  final Future<void> Function(ScannedProduct product) onProductConfirmed;
  final Future<void> Function(AddMealLogParams params) onMealSaved;

  ScannedProduct _toScannedProduct(MockScanResult result) {
    return ScannedProduct(
      id: result.id,
      productName: result.title,
      source: result.source,
      quantityLabel: result.mealSuggestion.portion,
      scannedAt: DateTime.now(),
      isMealLike: result.isMealLike,
      brandName: result.brandName,
      barcode: result.barcode,
      ingredients: result.ingredients,
      insights: result.insights,
      tags: result.tags,
      confidenceLabel: result.confidenceLabel,
    );
  }

  Future<void> _confirm(BuildContext context) async {
    await onProductConfirmed(_toScannedProduct(mockFoodScanResult));
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _save(BuildContext context) async {
    await onProductConfirmed(_toScannedProduct(mockFoodScanResult));
    await onMealSaved(mockFoodScanResult.mealSuggestion.toAddMealParams());
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Food Mock')),
      body: SafeArea(
        child: MockScanResultView(
          result: mockFoodScanResult,
          onConfirmProduct: () => _confirm(context),
          onSaveMeal: () => _save(context),
        ),
      ),
    );
  }
}
