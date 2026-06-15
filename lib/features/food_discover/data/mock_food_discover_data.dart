import '../../nutrition/application/usecases/add_meal_log_usecase.dart';
import '../../nutrition/domain/entities/meal_log.dart';
import '../domain/bought_food_item.dart';
import '../domain/food_recommendation.dart';

final mockFoodRecommendations = <FoodRecommendation>[
  const FoodRecommendation(
    id: 'rec_001',
    section: 'Good for today',
    title: 'Egg and tofu rice bowl',
    description: 'Balanced meal idea with protein and carbs for steady energy.',
    tags: ['balanced', 'home_cooking'],
    mealSuggestion: AddMealLogParams(
      mealType: MealType.lunch,
      foodName: 'Egg and tofu rice bowl',
      portion: '1 bowl',
      calories: 520,
      protein: 28,
      carbs: 64,
      fat: 16,
      tags: ['balanced', 'home_cooking'],
    ),
  ),
  const FoodRecommendation(
    id: 'rec_002',
    section: 'High protein options',
    title: 'Greek yogurt with fruit',
    description: 'A normal food option that can support protein intake.',
    tags: ['high_protein', 'snack'],
    mealSuggestion: AddMealLogParams(
      mealType: MealType.snack,
      foodName: 'Greek yogurt with fruit',
      portion: '1 bowl',
      calories: 240,
      protein: 18,
      carbs: 32,
      fat: 4,
      tags: ['high_protein', 'snack'],
    ),
  ),
  const FoodRecommendation(
    id: 'rec_003',
    section: 'Light meal ideas',
    title: 'Vegetable soup with beans',
    description: 'Simple, warm, and filling without feeling heavy.',
    tags: ['light', 'fiber'],
    mealSuggestion: AddMealLogParams(
      mealType: MealType.dinner,
      foodName: 'Vegetable soup with beans',
      portion: '1 bowl',
      calories: 330,
      protein: 14,
      carbs: 48,
      fat: 8,
      tags: ['light', 'fiber'],
    ),
  ),
  const FoodRecommendation(
    id: 'rec_004',
    section: 'Simple ingredients',
    title: 'Beans, eggs, tofu, bananas',
    description: 'Everyday ingredients for quick home cooking.',
    tags: ['easy', 'budget_friendly'],
  ),
];

final mockBoughtToday = <BoughtFoodItem>[
  BoughtFoodItem(
    id: 'bought_001',
    productName: 'Bananas',
    source: 'manual',
    quantityLabel: '4 pieces',
    addedAt: DateTime.now().copyWith(hour: 17, minute: 0),
    canAddAsMeal: false,
    tags: ['fruit', 'bought_today'],
  ),
];
