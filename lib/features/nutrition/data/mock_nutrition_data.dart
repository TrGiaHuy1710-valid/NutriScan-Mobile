import '../domain/entities/meal_log.dart';

final mockMealLogs = <MealLog>[
  MealLog(
    id: 'meal_002',
    mealType: MealType.lunch,
    foodName: 'Rice with chicken and vegetables',
    portion: '1 plate',
    calories: 620,
    protein: 35,
    carbs: 75,
    fat: 18,
    createdAt: DateTime.now().copyWith(hour: 12, minute: 30),
    tags: const ['lunch', 'balanced'],
  ),
  MealLog(
    id: 'meal_001',
    mealType: MealType.breakfast,
    foodName: 'Oatmeal with banana',
    portion: '1 bowl',
    calories: 320,
    protein: 10,
    carbs: 55,
    fat: 7,
    createdAt: DateTime.now().copyWith(hour: 8, minute: 0),
    tags: const ['breakfast', 'high_fiber'],
  ),
];
