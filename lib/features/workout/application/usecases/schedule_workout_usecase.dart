import '../../../calendar/domain/entities/free_time_slot.dart';
import '../../domain/entities/workout_plan.dart';
import '../../domain/repositories/workout_repository.dart';

class ScheduleWorkoutUseCase {
  const ScheduleWorkoutUseCase(this.repository);

  final WorkoutRepository repository;

  Future<WorkoutPlan> call({
    required WorkoutPlan workout,
    required FreeTimeSlot slot,
  }) {
    return repository.scheduleWorkout(workout: workout, slot: slot);
  }
}
