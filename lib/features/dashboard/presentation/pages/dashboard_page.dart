import 'package:flutter/material.dart';

import '../../../../features/dashboard/domain/entities/daily_health_stats.dart';
import '../../../../features/dashboard/presentation/widgets/metric_chip.dart';
import '../../../../features/dashboard/presentation/widgets/section_card.dart';
import '../../../../features/food_discover/domain/bought_food_item.dart';
import '../../../../features/nutrition/domain/entities/meal_log.dart';
import '../../../../features/nutrition/domain/entities/nutrition_summary.dart';
import '../../../../features/nutrition/presentation/widgets/meal_log_tile.dart';
import '../../../../features/workout/domain/entities/workout_plan.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.meals,
    required this.summary,
    required this.dailyStats,
    required this.boughtToday,
    required this.workoutToday,
    required this.onAddMeal,
    required this.onPlanWorkout,
    required this.onViewHealthStats,
    super.key,
  });

  final List<MealLog> meals;
  final NutritionSummary summary;
  final DailyHealthStats dailyStats;
  final List<BoughtFoodItem> boughtToday;
  final WorkoutPlan? workoutToday;
  final VoidCallback onAddMeal;
  final VoidCallback onPlanWorkout;
  final VoidCallback onViewHealthStats;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Today')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Good morning, Huy',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text('Small choices, clear picture.', style: textTheme.bodyLarge),
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calories balance', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    '${dailyStats.netCalories} net kcal',
                    key: const Key('calorieSummaryText'),
                    style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dailyStats.remainingCalories} kcal remaining against today\'s mock target.',
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  _CaloriesBalanceBar(stats: dailyStats),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatPill(
                        label: 'Eaten',
                        value: '${dailyStats.intakeCalories} kcal',
                      ),
                      _StatPill(
                        label: 'Estimated burned',
                        value: '${dailyStats.burnedCalories} kcal',
                      ),
                      _StatPill(
                        label: 'Target',
                        value: '${dailyStats.targetCalories} kcal',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MetricChip(
                    label: 'Protein',
                    value: '${summary.totalProtein}g',
                    icon: Icons.egg_alt_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MetricChip(
                    label: 'Carbs',
                    value: '${summary.totalCarbs}g',
                    icon: Icons.grain,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MetricChip(
                    label: 'Fat',
                    value: '${summary.totalFat}g',
                    icon: Icons.water_drop_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick actions', style: textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        key: const Key('dashboardAddMealButton'),
                        onPressed: onAddMeal,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Meal'),
                      ),
                      OutlinedButton.icon(
                        key: const Key('dashboardPlanWorkoutButton'),
                        onPressed: onPlanWorkout,
                        icon: const Icon(Icons.fitness_center),
                        label: const Text('Plan Workout'),
                      ),
                      OutlinedButton.icon(
                        key: const Key('dashboardHealthStatsButton'),
                        onPressed: onViewHealthStats,
                        icon: const Icon(Icons.insights_outlined),
                        label: const Text('Health Stats'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bought today', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (boughtToday.isEmpty)
                    const Text('No foods or products confirmed today.')
                  else
                    ...boughtToday
                        .take(3)
                        .map(
                          (item) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.shopping_bag_outlined),
                            title: Text(item.productName),
                            subtitle: Text(item.quantityLabel),
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Workout today', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    workoutToday != null && workoutToday!.isScheduled
                        ? '${workoutToday!.title} - ${workoutToday!.durationMinutes} min'
                        : 'Not scheduled yet',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    workoutToday != null && workoutToday!.isCompleted
                        ? 'Completed. Estimated ${workoutToday!.estimatedCaloriesBurned} kcal burned added to today.'
                        : 'Fake calendar slots are ready when you want to plan.',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Meals today', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (meals.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('No meals logged yet.'),
                    )
                  else
                    ...meals.map((meal) => MealLogTile(meal: meal)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaloriesBalanceBar extends StatelessWidget {
  const _CaloriesBalanceBar({required this.stats});

  final DailyHealthStats stats;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final remainingProgress = (1 - stats.intakeProgress)
        .clamp(0.0, 1.0)
        .toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                Expanded(
                  flex: (stats.intakeProgress * 100).round().clamp(1, 100),
                  child: ColoredBox(color: colorScheme.primary),
                ),
                Expanded(
                  flex: (remainingProgress * 100).round().clamp(1, 100),
                  child: ColoredBox(color: colorScheme.surfaceContainerHighest),
                ),
                if (stats.burnedCalories > 0)
                  Expanded(
                    flex: (stats.burnedProgress * 100).round().clamp(1, 100),
                    child: ColoredBox(color: colorScheme.tertiary),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: const [
            _LegendDot(label: 'Eaten', icon: Icons.circle),
            _LegendDot(label: 'Remaining', icon: Icons.circle_outlined),
            _LegendDot(label: 'Burned', icon: Icons.local_fire_department),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    );
  }
}
