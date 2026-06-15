import 'package:flutter/foundation.dart';

import '../../application/usecases/get_scheduled_workout_usecase.dart';
import '../../application/usecases/get_workout_suggestions_usecase.dart';
import '../../application/usecases/schedule_workout_usecase.dart';
import '../../application/usecases/complete_workout_usecase.dart';
import '../../domain/entities/workout_plan.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/daily_workout_plan.dart';
import '../../../calendar/application/usecases/get_free_time_slots_usecase.dart';
import '../../../calendar/domain/entities/free_time_slot.dart';
import 'workout_state.dart';

class WorkoutCubit extends ChangeNotifier {
  WorkoutCubit({
    required GetFreeTimeSlotsUseCase getFreeTimeSlotsUseCase,
    required GetWorkoutSuggestionsUseCase getWorkoutSuggestionsUseCase,
    required GetScheduledWorkoutUseCase getScheduledWorkoutUseCase,
    required ScheduleWorkoutUseCase scheduleWorkoutUseCase,
    required CompleteWorkoutUseCase completeWorkoutUseCase,
  }) : _getFreeTimeSlotsUseCase = getFreeTimeSlotsUseCase,
       _getWorkoutSuggestionsUseCase = getWorkoutSuggestionsUseCase,
       _getScheduledWorkoutUseCase = getScheduledWorkoutUseCase,
       _scheduleWorkoutUseCase = scheduleWorkoutUseCase,
       _completeWorkoutUseCase = completeWorkoutUseCase;

  final GetFreeTimeSlotsUseCase _getFreeTimeSlotsUseCase;
  final GetWorkoutSuggestionsUseCase _getWorkoutSuggestionsUseCase;
  final GetScheduledWorkoutUseCase _getScheduledWorkoutUseCase;
  final ScheduleWorkoutUseCase _scheduleWorkoutUseCase;
  final CompleteWorkoutUseCase _completeWorkoutUseCase;

  WorkoutState _state = WorkoutState.initial();

  WorkoutState get state => _state;

  void selectSlot(FreeTimeSlot? slot) {
    _emit(_state.copyWith(selectedSlot: slot, clearSelectedSlot: slot == null));
  }

  Future<void> loadWorkoutPlan() async {
    _emit(_state.copyWith(status: WorkoutStatus.loading));

    try {
      final slots = await _getFreeTimeSlotsUseCase();
      // Sort slots by duration to display them in order (15m, 30m, 45m, 60m, 90m)
      slots.sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));

      final suggestions = await _getWorkoutSuggestionsUseCase();
      final scheduledWorkout = await _getScheduledWorkoutUseCase();
      
      _emit(
        WorkoutState(
          status: WorkoutStatus.loaded,
          freeTimeSlots: slots,
          workoutSuggestions: suggestions,
          scheduledWorkout: scheduledWorkout,
          calendarEvents: _generateMockCalendarEvents(),
          upcomingPlans: _generateMockUpcomingPlans(scheduledWorkout),
        ),
      );
    } catch (_) {
      _emit(
        _state.copyWith(
          status: WorkoutStatus.failure,
          errorMessage: 'Unable to load workout suggestions right now.',
        ),
      );
    }
  }

  Future<void> scheduleWorkout({
    required WorkoutPlan workout,
    FreeTimeSlot? slot,
  }) async {
    final selectedSlot =
        slot ??
        _state.selectedSlot ??
        (_state.freeTimeSlots.isEmpty ? null : _state.freeTimeSlots.first);
    if (selectedSlot == null) {
      _emit(
        _state.copyWith(
          status: WorkoutStatus.failure,
          errorMessage: 'No free time slot is available.',
        ),
      );
      return;
    }

    try {
      final scheduledWorkout = await _scheduleWorkoutUseCase(
        workout: workout,
        slot: selectedSlot,
      );
      _emit(
        _state.copyWith(
          scheduledWorkout: scheduledWorkout,
          upcomingPlans: _generateMockUpcomingPlans(scheduledWorkout),
        ),
      );
    } catch (_) {
      _emit(
        _state.copyWith(
          status: WorkoutStatus.failure,
          errorMessage: 'Unable to schedule this workout right now.',
        ),
      );
    }
  }

  Future<void> completeWorkout(WorkoutPlan workout) async {
    try {
      final completedWorkout = await _completeWorkoutUseCase(workout);
      _emit(
        _state.copyWith(
          scheduledWorkout: completedWorkout,
          upcomingPlans: _generateMockUpcomingPlans(completedWorkout),
        ),
      );
    } catch (_) {
      _emit(
        _state.copyWith(
          status: WorkoutStatus.failure,
          errorMessage: 'Unable to complete this workout right now.',
        ),
      );
    }
  }

  List<CalendarEvent> _generateMockCalendarEvents() {
    final today = DateTime.now();
    return [
      CalendarEvent(
        id: 'cal_event_001',
        title: 'Team Meeting',
        startTime: DateTime(today.year, today.month, today.day, 9, 0),
        endTime: DateTime(today.year, today.month, today.day, 10, 0),
      ),
      CalendarEvent(
        id: 'cal_event_002',
        title: 'Lunch',
        startTime: DateTime(today.year, today.month, today.day, 11, 0),
        endTime: DateTime(today.year, today.month, today.day, 12, 0),
      ),
    ];
  }

  List<DailyWorkoutPlan> _generateMockUpcomingPlans(WorkoutPlan? scheduled) {
    final today = DateTime.now();
    final currentWeekday = today.weekday; // 1 = Monday, 7 = Sunday
    
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final baseWorkouts = [
      'Upper Body',
      'Recovery Walk',
      'HIIT',
      'Core Training',
      'Full Body',
      'Yoga Flow',
      'Rest Day'
    ];

    List<DailyWorkoutPlan> plans = [];
    for (int i = 1; i <= 7; i++) {
      final daysDiff = i - currentWeekday;
      final dateForDay = today.add(Duration(days: daysDiff));
      final isToday = (i == currentWeekday);
      
      plans.add(
        DailyWorkoutPlan(
          dayName: weekdays[i - 1],
          workoutName: baseWorkouts[i - 1],
          date: dateForDay,
          isRestDay: (i == 7),
          scheduledWorkout: isToday ? scheduled : null,
        ),
      );
    }
    return plans;
  }

  void _emit(WorkoutState state) {
    _state = state;
    notifyListeners();
  }
}
