import '../../../calendar/domain/entities/free_time_slot.dart';
import '../../domain/entities/workout_plan.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/daily_workout_plan.dart';

enum WorkoutStatus { initial, loading, loaded, failure }

class WorkoutState {
  const WorkoutState({
    required this.status,
    required this.freeTimeSlots,
    required this.workoutSuggestions,
    this.scheduledWorkout,
    this.errorMessage,
    this.selectedSlot,
    this.calendarEvents = const [],
    this.upcomingPlans = const [],
  });

  factory WorkoutState.initial() {
    return const WorkoutState(
      status: WorkoutStatus.initial,
      freeTimeSlots: [],
      workoutSuggestions: [],
      calendarEvents: [],
      upcomingPlans: [],
    );
  }

  final WorkoutStatus status;
  final List<FreeTimeSlot> freeTimeSlots;
  final List<WorkoutPlan> workoutSuggestions;
  final WorkoutPlan? scheduledWorkout;
  final String? errorMessage;
  final FreeTimeSlot? selectedSlot;
  final List<CalendarEvent> calendarEvents;
  final List<DailyWorkoutPlan> upcomingPlans;

  WorkoutState copyWith({
    WorkoutStatus? status,
    List<FreeTimeSlot>? freeTimeSlots,
    List<WorkoutPlan>? workoutSuggestions,
    WorkoutPlan? scheduledWorkout,
    String? errorMessage,
    FreeTimeSlot? selectedSlot,
    bool clearSelectedSlot = false,
    List<CalendarEvent>? calendarEvents,
    List<DailyWorkoutPlan>? upcomingPlans,
  }) {
    return WorkoutState(
      status: status ?? this.status,
      freeTimeSlots: freeTimeSlots ?? this.freeTimeSlots,
      workoutSuggestions: workoutSuggestions ?? this.workoutSuggestions,
      scheduledWorkout: scheduledWorkout ?? this.scheduledWorkout,
      errorMessage: errorMessage,
      selectedSlot: clearSelectedSlot ? null : (selectedSlot ?? this.selectedSlot),
      calendarEvents: calendarEvents ?? this.calendarEvents,
      upcomingPlans: upcomingPlans ?? this.upcomingPlans,
    );
  }
}

