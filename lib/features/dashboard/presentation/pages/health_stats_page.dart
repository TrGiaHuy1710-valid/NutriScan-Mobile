import 'package:flutter/material.dart';

import '../../../../features/dashboard/domain/entities/daily_health_stats.dart';
import '../../../../features/dashboard/presentation/widgets/section_card.dart';
import '../../../../features/nutrition/domain/entities/nutrition_summary.dart';
import '../../../../features/workout/domain/entities/workout_plan.dart';

class HealthStatsPage extends StatelessWidget {
  const HealthStatsPage({
    required this.summary,
    required this.dailyStats,
    required this.workoutToday,
    super.key,
  });

  final NutritionSummary summary;
  final DailyHealthStats dailyStats;
  final WorkoutPlan? workoutToday;

  @override
  Widget build(BuildContext context) {
    final calorieProgress = dailyStats.intakeProgress;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Health Stats')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Progress overview',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text('Simple local indicators for today and recent days.'),
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily target', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    '${dailyStats.netCalories} net / ${dailyStats.targetCalories} kcal target',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dailyStats.intakeCalories} eaten - ${dailyStats.burnedCalories} estimated burned',
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: calorieProgress,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 12),
                  Text(_calorieNotice(summary.totalCalories)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Macros today', style: textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _ProgressRow(
                    label: 'Protein',
                    value: summary.totalProtein,
                    max: 120,
                  ),
                  _ProgressRow(
                    label: 'Carbs',
                    value: summary.totalCarbs,
                    max: 260,
                  ),
                  _ProgressRow(label: 'Fat', value: summary.totalFat, max: 80),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calories by day', style: textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _CaloriesByDayChart(todayCalories: dailyStats.intakeCalories),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Workout goal', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    workoutToday != null && workoutToday!.isCompleted
                        ? '${workoutToday!.title} completed. Estimated ${workoutToday!.estimatedCaloriesBurned} kcal burned.'
                        : workoutToday != null && workoutToday!.isScheduled
                        ? '${workoutToday!.title} is scheduled today.'
                        : 'Your workout goal is not scheduled yet.',
                  ),
                  const SizedBox(height: 12),
                  _ProgressRow(
                    label: 'Workout minutes',
                    value: workoutToday?.durationMinutes ?? 0,
                    max: 30,
                    suffix: 'min',
                  ),
                  _ProgressRow(
                    label: 'Workout calories burned',
                    value: workoutToday?.isCompleted == true
                        ? workoutToday!.estimatedCaloriesBurned
                        : 0,
                    max: 180,
                    suffix: 'kcal',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('This week', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('Average intake: 1,640 kcal'),
                  const Text('Average burned: 95 kcal'),
                  const Text('Days logged: 5'),
                  Text(
                    workoutToday?.isCompleted == true
                        ? 'Completed workouts: 1'
                        : 'Completed workouts: 0',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('This month', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('Mock range summary is local-only for now.'),
                  const Text('Workout minutes: 120'),
                  const Text('Workout calories burned: 520'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calorieNotice(int calories) {
    if (calories > 2200) {
      return 'You are above your planned intake today. Keep the next meal balanced and gentle.';
    }
    if (calories < 900) {
      return 'You may need more balanced meals today, depending on your routine.';
    }
    return 'Your intake looks steady for a normal habit-tracking day.';
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.value,
    required this.max,
    this.suffix = 'g',
  });

  final String label;
  final int value;
  final int max;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: $value$suffix'),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: (value / max).clamp(0.0, 1.0).toDouble(),
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
    );
  }
}

class _CaloriesByDayChart extends StatelessWidget {
  const _CaloriesByDayChart({required this.todayCalories});

  final int todayCalories;

  @override
  Widget build(BuildContext context) {
    final values = [
      const _ChartDay(label: 'Mon', intake: 1200, burned: 40),
      const _ChartDay(label: 'Tue', intake: 1600, burned: 80),
      const _ChartDay(label: 'Wed', intake: 1800, burned: 120),
      _ChartDay(label: 'Today', intake: todayCalories, burned: 0),
      const _ChartDay(label: 'Fri', intake: 1400, burned: 0),
    ];

    return SizedBox(
      height: 168,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values
            .map(
              (day) => Expanded(
                child: _VerticalBar(
                  label: day.label,
                  intake: day.intake,
                  burned: day.burned,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ChartDay {
  const _ChartDay({
    required this.label,
    required this.intake,
    required this.burned,
  });

  final String label;
  final int intake;
  final int burned;
}

class _VerticalBar extends StatelessWidget {
  const _VerticalBar({
    required this.label,
    required this.intake,
    required this.burned,
  });

  final String label;
  final int intake;
  final int burned;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final intakeHeight = (intake / 2200 * 100).clamp(8.0, 112.0);
    final burnedHeight = (burned / 2200 * 100).clamp(0.0, 34.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('$intake', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        SizedBox(
          height: 118,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (burned > 0)
                    Container(
                      width: 28,
                      height: burnedHeight,
                      color: colorScheme.tertiary,
                    ),
                  Container(
                    width: 28,
                    height: intakeHeight,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
