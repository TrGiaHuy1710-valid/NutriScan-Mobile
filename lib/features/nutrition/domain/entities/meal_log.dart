enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }
}

class MealLog {
  const MealLog({
    required this.id,
    required this.mealType,
    required this.foodName,
    required this.portion,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.createdAt,
    this.tags = const [],
  });

  final String id;
  final MealType mealType;
  final String foodName;
  final String portion;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final DateTime createdAt;
  final List<String> tags;
}
