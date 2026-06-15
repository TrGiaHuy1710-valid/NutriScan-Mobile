import '../../../calendar/domain/entities/free_time_slot.dart';
import '../entities/workout_plan.dart';

abstract class WorkoutRepository {
  Future<List<WorkoutPlan>> getWorkoutSuggestions();

  Future<WorkoutPlan?> getScheduledWorkoutToday();

  Future<WorkoutPlan> scheduleWorkout({
    required WorkoutPlan workout,
    required FreeTimeSlot slot,
  });

  Future<WorkoutPlan> completeWorkout(WorkoutPlan workout);
}
