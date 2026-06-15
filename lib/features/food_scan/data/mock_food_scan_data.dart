import '../../nutrition/domain/entities/meal_log.dart';
import '../domain/ingredient_insight.dart';
import '../domain/mock_scan_result.dart';
import '../domain/scan_meal_suggestion.dart';

const mockFoodScanResult = MockScanResult(
  id: 'scan_food_001',
  title: 'Rice bowl with egg',
  subtitle: 'Mock food image estimate',
  badge: 'Food scan mock',
  source: 'food_scan_mock',
  mealSuggestion: ScanMealSuggestion(
    mealType: MealType.lunch,
    foodName: 'Rice bowl with egg',
    portion: '1 bowl',
    calories: 540,
    protein: 22,
    carbs: 74,
    fat: 16,
    tags: ['lunch', 'balanced', 'quick_meal'],
  ),
  tags: ['lunch', 'balanced', 'quick_meal'],
  insights: [
    IngredientInsight(
      type: 'estimate',
      level: 'medium',
      message: 'Calories are estimated from a fake visual match.',
    ),
    IngredientInsight(
      type: 'protein',
      level: 'medium',
      message: 'Egg may add a helpful protein boost.',
    ),
  ],
);

const mockIngredientScanResult = MockScanResult(
  id: 'scan_ingredient_001',
  title: 'Chocolate Milk',
  subtitle: 'Mock ingredient label result',
  badge: 'Ingredient scan mock',
  source: 'ingredient_label',
  brandName: 'Mock Dairy',
  ingredients: ['milk', 'sugar', 'cocoa powder', 'stabilizer', 'salt'],
  mealSuggestion: ScanMealSuggestion(
    mealType: MealType.snack,
    foodName: 'Chocolate Milk',
    portion: '1 bottle',
    calories: 210,
    protein: 8,
    carbs: 32,
    fat: 5,
    tags: ['snack', 'recently_scanned'],
  ),
  tags: ['snack', 'recently_scanned', 'bought_today'],
  insights: [
    IngredientInsight(
      type: 'sugar',
      level: 'high',
      message: 'This product appears to contain added sugar.',
    ),
    IngredientInsight(
      type: 'protein',
      level: 'medium',
      message: 'Milk may provide some protein.',
    ),
  ],
);

const mockBarcodeScanResult = MockScanResult(
  id: 'scan_barcode_001',
  title: 'Granola Bar',
  subtitle: 'Mock barcode product lookup',
  badge: 'Barcode mock',
  source: 'barcode',
  brandName: 'Mock Pantry',
  barcode: '8930000001234',
  ingredients: ['oats', 'honey', 'peanuts', 'rice crisps', 'salt'],
  mealSuggestion: ScanMealSuggestion(
    mealType: MealType.snack,
    foodName: 'Granola Bar',
    portion: '1 bar',
    calories: 180,
    protein: 5,
    carbs: 29,
    fat: 6,
    tags: ['snack', 'high_fiber', 'recently_scanned'],
  ),
  tags: ['snack', 'high_fiber', 'bought_today'],
  insights: [
    IngredientInsight(
      type: 'fiber',
      level: 'medium',
      message: 'Oats may provide some fiber.',
    ),
    IngredientInsight(
      type: 'sodium',
      level: 'low',
      message: 'This mock product has a modest sodium note.',
    ),
  ],
);
