import 'package:flutter/material.dart';

import '../../../food_discover/domain/scanned_product.dart';
import '../../../nutrition/application/usecases/add_meal_log_usecase.dart';
import '../../data/mock_food_scan_data.dart';
import '../../domain/mock_scan_result.dart';
import '../widgets/mock_scan_result_view.dart';

class ScanBarcodePage extends StatelessWidget {
  const ScanBarcodePage({
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
    await onProductConfirmed(_toScannedProduct(mockBarcodeScanResult));
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _save(BuildContext context) async {
    await onProductConfirmed(_toScannedProduct(mockBarcodeScanResult));
    await onMealSaved(mockBarcodeScanResult.mealSuggestion.toAddMealParams());
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode Mock')),
      body: SafeArea(
        child: MockScanResultView(
          result: mockBarcodeScanResult,
          onConfirmProduct: () => _confirm(context),
          onSaveMeal: () => _save(context),
        ),
      ),
    );
  }
}
