import 'package:flutter/material.dart';

import '../../../calendar/domain/entities/free_time_slot.dart';
import '../../domain/entities/workout_plan.dart';

class WorkoutSuggestionScreen extends StatelessWidget {
  const WorkoutSuggestionScreen({
    required this.selectedSlot,
    required this.workoutSuggestions,
    required this.onScheduleWorkout,
    super.key,
  });

  final FreeTimeSlot selectedSlot;
  final List<WorkoutPlan> workoutSuggestions;
  final ValueChanged<WorkoutPlan> onScheduleWorkout;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Filter suggestions matching the selected slot duration
    final matchingWorkouts = workoutSuggestions
        .where((w) => w.durationMinutes == selectedSlot.durationMinutes)
        .toList();

    // Filter other suggestions
    final otherWorkouts = workoutSuggestions
        .where((w) => w.durationMinutes != selectedSlot.durationMinutes)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Suggestions'),
        leading: IconButton(
          key: const Key('suggestionScreenBackButton'),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            // Selected Time Slot Info Header
            Card(
              elevation: 0,
              color: colorScheme.secondaryContainer.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colorScheme.secondaryContainer,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.hourglass_empty,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Target Time Slot',
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${selectedSlot.durationMinutes} Minutes Available',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Scheduled: ${_formatTime(selectedSlot.startTime)} - ${_formatTime(selectedSlot.endTime)}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section 1: Matching Suggestions
            Text(
              'Perfect Matches (${matchingWorkouts.length})',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'These workouts fit perfectly into your selected free time.',
              style: textTheme.bodyMedium?.copyWith(
                color: textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            if (matchingWorkouts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No workouts match this duration exactly.',
                    style: textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              ...matchingWorkouts.map(
                (workout) => _WorkoutSuggestionCard(
                  key: Key('workoutCard_${workout.id}'),
                  workout: workout,
                  selectedSlot: selectedSlot,
                  onSchedule: () => _handleSchedule(context, workout),
                  isMatch: true,
                ),
              ),

            const SizedBox(height: 24),

            // Section 2: Other suggestions for validation and options
            Text(
              'Other Workouts',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Workouts with different durations. Try scheduling one to test validation limits.',
              style: textTheme.bodyMedium?.copyWith(
                color: textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            ...otherWorkouts.map(
              (workout) => _WorkoutSuggestionCard(
                key: Key('workoutCard_${workout.id}'),
                workout: workout,
                selectedSlot: selectedSlot,
                onSchedule: () => _handleSchedule(context, workout),
                isMatch: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSchedule(BuildContext context, WorkoutPlan workout) {
    if (workout.durationMinutes > selectedSlot.durationMinutes) {
      showDialog(
        context: context,
        key: const Key('scheduleValidationDialog'),
        builder: (context) => AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text('Time Check'),
            ],
          ),
          content: const Text('Workout exceeds your available free time.'),
          actions: [
            TextButton(
              key: const Key('validationDialogOkButton'),
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      onScheduleWorkout(workout);
      Navigator.pop(context);
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _WorkoutSuggestionCard extends StatelessWidget {
  const _WorkoutSuggestionCard({
    required this.workout,
    required this.selectedSlot,
    required this.onSchedule,
    required this.isMatch,
    super.key,
  });

  final WorkoutPlan workout;
  final FreeTimeSlot selectedSlot;
  final VoidCallback onSchedule;
  final bool isMatch;

  Color _getDifficultyColor(String difficulty, ThemeData theme) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green.shade600;
      case 'intermediate':
        return Colors.orange.shade600;
      case 'advanced':
        return Colors.red.shade600;
      default:
        return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isMatch ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isMatch ? colorScheme.primary : colorScheme.outlineVariant,
          width: isMatch ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    workout.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isMatch)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Perfect Match',
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${workout.durationMinutes} min',
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Difficulty Chip
                _buildCardChip(
                  context,
                  label: workout.difficulty,
                  color: _getDifficultyColor(workout.difficulty, theme),
                  icon: Icons.fitness_center,
                ),
                // Calories Chip
                _buildCardChip(
                  context,
                  label: '${workout.estimatedCaloriesBurned} kcal',
                  color: Colors.orange.shade700,
                  icon: Icons.local_fire_department,
                ),
                // Equipment Chip
                _buildCardChip(
                  context,
                  label: workout.equipment,
                  color: colorScheme.secondary,
                  icon: Icons.handyman_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Exercise Blocks & Duration:',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            // Exercises details (Step list)
            ...workout.exercises.asMap().entries.map((entry) {
              final idx = entry.key;
              final block = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle_notifications_outlined,
                      size: 18,
                      color: colorScheme.primary.withOpacity(0.8),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        block,
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total duration: ${workout.durationMinutes} min',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FilledButton.icon(
                  key: Key('scheduleWorkoutButton_${workout.id}'),
                  onPressed: onSchedule,
                  icon: const Icon(Icons.event_available),
                  label: const Text('Schedule Workout'),
                  style: FilledButton.styleFrom(
                    backgroundColor: isMatch ? null : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardChip(
    BuildContext context, {
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
