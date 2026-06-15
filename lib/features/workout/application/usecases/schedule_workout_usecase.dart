import '../../../calendar/domain/entities/free_time_slot.dart';
import '../../domain/entities/workout_plan.dart';
import '../../domain/repositories/workout_repository.dart';

class ScheduleWorkoutUseCase {
  const ScheduleWorkoutUseCase(this._repository);

  final WorkoutRepository _repository;

  Future<WorkoutPlan> call({
    required WorkoutPlan workout,
    required FreeTimeSlot slot,
  }) {
    return _repository.scheduleWorkout(workout: workout, slot: slot);
  }
}
