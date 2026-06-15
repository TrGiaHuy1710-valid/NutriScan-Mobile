import '../domain/entities/meal_log.dart';

extension MealLogJson on MealLog {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mealType': mealType.name,
      'foodName': foodName,
      'portion': portion,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
    };
  }
}

MealLog mealLogFromJson(Map<String, dynamic> json) {
  return MealLog(
    id: json['id'] as String? ?? 'meal_local',
    mealType: MealType.values.firstWhere(
      (type) => type.name == json['mealType'],
      orElse: () => MealType.snack,
    ),
    foodName: json['foodName'] as String? ?? 'Saved food',
    portion: json['portion'] as String? ?? '1 serving',
    calories: json['calories'] as int? ?? 0,
    protein: json['protein'] as int? ?? 0,
    carbs: json['carbs'] as int? ?? 0,
    fat: json['fat'] as int? ?? 0,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    tags: (json['tags'] as List?)?.whereType<String>().toList() ?? const [],
  );
}
