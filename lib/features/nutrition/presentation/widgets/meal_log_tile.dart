import 'package:flutter/material.dart';

import '../../domain/entities/meal_log.dart';

class MealLogTile extends StatelessWidget {
  const MealLogTile({required this.meal, super.key});

  final MealLog meal;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        child: Text(meal.mealType.label.substring(0, 1)),
      ),
      title: Text(
        meal.foodName,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text('${meal.mealType.label} - ${meal.portion}'),
      trailing: Text(
        '${meal.calories} cal',
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}
