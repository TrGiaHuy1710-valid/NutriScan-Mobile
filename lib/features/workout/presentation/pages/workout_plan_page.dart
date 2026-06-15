import 'package:flutter/material.dart';

import '../../../calendar/domain/entities/free_time_slot.dart';
import '../../domain/entities/workout_plan.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/daily_workout_plan.dart';
import 'workout_suggestion_screen.dart';

class WorkoutPlanPage extends StatefulWidget {
  const WorkoutPlanPage({
    required this.freeTimeSlots,
    required this.workoutSuggestions,
    required this.scheduledWorkout,
    required this.selectedSlot,
    required this.calendarEvents,
    required this.upcomingPlans,
    required this.onWorkoutScheduled,
    required this.onWorkoutCompleted,
    required this.onSelectSlot,
    super.key,
  });

  final List<FreeTimeSlot> freeTimeSlots;
  final List<WorkoutPlan> workoutSuggestions;
  final WorkoutPlan? scheduledWorkout;
  final FreeTimeSlot? selectedSlot;
  final List<CalendarEvent> calendarEvents;
  final List<DailyWorkoutPlan> upcomingPlans;
  final ValueChanged<WorkoutPlan> onWorkoutScheduled;
  final ValueChanged<WorkoutPlan> onWorkoutCompleted;
  final ValueChanged<FreeTimeSlot?> onSelectSlot;

  @override
  State<WorkoutPlanPage> createState() => _WorkoutPlanPageState();
}

class _WorkoutPlanPageState extends State<WorkoutPlanPage> {
  String _selectedTimelineFilter = 'Next 7 Days';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Build today's schedule timeline items combining calendar events and the scheduled workout
    final timelineItems = _buildTimelineItems();

    // Filter upcoming plans based on the selected filter
    final filteredPlans = _getFilteredPlans();

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Plan')),
      body: SafeArea(
        child: ListView(
          key: const Key('workoutPlanList'),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            // Section 1: Free Time Today
            Text(
              'Free Time Today',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap a slot to view and schedule matching workout suggestions.',
              style: textTheme.bodyMedium?.copyWith(
                color: textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 72,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.freeTimeSlots.length,
                itemBuilder: (context, index) {
                  final slot = widget.freeTimeSlots[index];
                  final isSelected = widget.selectedSlot?.durationMinutes == slot.durationMinutes;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _SlotChip(
                      key: Key('freeTimeChip_${slot.durationMinutes}m'),
                      slot: slot,
                      isSelected: isSelected,
                      onTap: () {
                        widget.onSelectSlot(slot);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => WorkoutSuggestionScreen(
                              selectedSlot: slot,
                              workoutSuggestions: widget.workoutSuggestions,
                              onScheduleWorkout: widget.onWorkoutScheduled,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: Today's Schedule (Timeline)
            Text(
              'Today\'s Schedule',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Mock calendar events combined with scheduled workout plans.',
              style: textTheme.bodyMedium?.copyWith(
                color: textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            if (timelineItems.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No events or workouts scheduled today.'),
                ),
              )
            else
              ...timelineItems.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                return _TimelineEventRow(
                  key: Key('timelineRow_$idx'),
                  timeLabel: item.timeLabel,
                  title: item.title,
                  subtitle: item.subtitle,
                  badge: item.badge,
                  isLast: idx == timelineItems.length - 1,
                  actionWidget: item.isWorkout && item.workout != null && !item.workout!.isCompleted
                      ? SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            key: Key('completeWorkoutButton_${item.workout!.id}'),
                            onPressed: () => widget.onWorkoutCompleted(item.workout!),
                            icon: const Icon(Icons.check),
                            label: const Text('Mark completed'),
                          ),
                        )
                      : null,
                );
              }),
            const SizedBox(height: 24),

            // Section 3: Workout Plan Timeline (Multi-day)
            Text(
              'Workout Plan Timeline',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Multi-day overview of your planned movement.',
              style: textTheme.bodyMedium?.copyWith(
                color: textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            // Timeline Filter Segment Controls
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Today', 'Tomorrow', 'Next 3 Days', 'Next 7 Days'].map((filter) {
                final isSelected = _selectedTimelineFilter == filter;
                return ChoiceChip(
                  key: Key('timelineFilterChip_$filter'),
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedTimelineFilter = filter;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ...filteredPlans.map((plan) {
              final isToday = _isSameDay(plan.date, DateTime.now());
              return Card(
                key: Key('upcomingPlanCard_${plan.dayName}'),
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isToday ? colorScheme.primary.withOpacity(0.5) : colorScheme.outlineVariant,
                    width: isToday ? 1.5 : 1,
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: plan.isRestDay
                        ? Colors.grey.shade100
                        : (plan.scheduledWorkout != null
                            ? Colors.green.shade50
                            : colorScheme.primaryContainer),
                    child: Icon(
                      plan.isRestDay
                          ? Icons.hotel
                          : (plan.scheduledWorkout != null
                              ? Icons.fitness_center
                              : Icons.directions_walk),
                      color: plan.isRestDay
                          ? Colors.grey
                          : (plan.scheduledWorkout != null
                              ? Colors.green.shade800
                              : colorScheme.onPrimaryContainer),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        plan.dayName,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isToday)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'TODAY',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        plan.isRestDay ? 'Rest & Recovery' : plan.workoutName,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: plan.scheduledWorkout != null ? FontWeight.normal : FontWeight.w600,
                          decoration: plan.scheduledWorkout?.isCompleted == true ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (plan.scheduledWorkout != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              plan.scheduledWorkout!.isCompleted ? Icons.check_circle : Icons.event_available,
                              size: 14,
                              color: plan.scheduledWorkout!.isCompleted ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                plan.scheduledWorkout!.isCompleted
                                    ? 'Completed: ${plan.scheduledWorkout!.title}'
                                    : 'Scheduled: ${plan.scheduledWorkout!.title} (${plan.scheduledWorkout!.durationMinutes}m)',
                                style: textTheme.bodySmall?.copyWith(
                                  color: plan.scheduledWorkout!.isCompleted ? Colors.green.shade800 : Colors.orange.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  trailing: Text(
                    _formatDate(plan.date),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  List<_TimelineItemData> _buildTimelineItems() {
    final list = <_TimelineItemData>[];

    // Add Calendar Events
    for (final event in widget.calendarEvents) {
      list.add(
        _TimelineItemData(
          title: event.title,
          timeLabel: '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
          startTime: event.startTime,
          isWorkout: false,
          subtitle: 'Google Calendar Event',
          badge: _buildBadge('Calendar', Colors.blue),
        ),
      );
    }

    // Add Scheduled Workout
    if (widget.scheduledWorkout != null && widget.scheduledWorkout!.isScheduled) {
      final workout = widget.scheduledWorkout!;
      final timeLabel = workout.scheduledStartTime != null && workout.scheduledEndTime != null
          ? '${_formatTime(workout.scheduledStartTime!)} - ${_formatTime(workout.scheduledEndTime!)}'
          : '${workout.durationMinutes}m';
      list.add(
        _TimelineItemData(
          title: workout.title,
          timeLabel: timeLabel,
          startTime: workout.scheduledStartTime ?? DateTime.now(),
          isWorkout: true,
          workout: workout,
          subtitle: workout.isCompleted
              ? 'Completed - Estimated ${workout.estimatedCaloriesBurned} kcal burned'
              : 'Scheduled Workout - ${workout.durationMinutes} min',
          badge: _buildBadge(
            workout.isCompleted ? 'Completed' : 'Workout',
            workout.isCompleted ? Colors.green : Colors.green,
          ),
        ),
      );
    }

    // Sort chronologically by start time
    list.sort((a, b) => a.startTime.compareTo(b.startTime));
    return list;
  }

  Widget _buildBadge(String label, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.shade200),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color.shade800,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  List<DailyWorkoutPlan> _getFilteredPlans() {
    final today = DateTime.now();
    switch (_selectedTimelineFilter) {
      case 'Today':
        return widget.upcomingPlans.where((p) => _isSameDay(p.date, today)).toList();
      case 'Tomorrow':
        final tomorrow = today.add(const Duration(days: 1));
        return widget.upcomingPlans.where((p) => _isSameDay(p.date, tomorrow)).toList();
      case 'Next 3 Days':
        final limit = today.add(const Duration(days: 3));
        return widget.upcomingPlans.where((p) => p.date.isBefore(limit)).toList();
      case 'Next 7 Days':
      default:
        return widget.upcomingPlans;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final FreeTimeSlot slot;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: isSelected ? 4 : 0,
      color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${slot.durationMinutes}m',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatTime(slot.startTime),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected ? colorScheme.onPrimary.withOpacity(0.8) : colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _TimelineItemData {
  _TimelineItemData({
    required this.title,
    required this.timeLabel,
    required this.startTime,
    required this.isWorkout,
    required this.subtitle,
    required this.badge,
    this.workout,
  });

  final String title;
  final String timeLabel;
  final DateTime startTime;
  final bool isWorkout;
  final String subtitle;
  final Widget badge;
  final WorkoutPlan? workout;
}

class _TimelineEventRow extends StatelessWidget {
  const _TimelineEventRow({
    required this.timeLabel,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.isLast,
    this.actionWidget,
    super.key,
  });

  final String timeLabel;
  final String title;
  final String subtitle;
  final Widget badge;
  final bool isLast;
  final Widget? actionWidget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Time label on the left
          SizedBox(
            width: 80,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                timeLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Timeline line and dot indicator
          Column(
            children: [
              const SizedBox(height: 18),
              Icon(
                Icons.radio_button_checked,
                size: 16,
                color: colorScheme.primary,
              ),
              Expanded(
                child: isLast
                    ? const SizedBox()
                    : Container(
                        width: 2,
                        color: colorScheme.outlineVariant,
                      ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          badge,
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (actionWidget != null) ...[
                        const SizedBox(height: 12),
                        actionWidget!,
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
