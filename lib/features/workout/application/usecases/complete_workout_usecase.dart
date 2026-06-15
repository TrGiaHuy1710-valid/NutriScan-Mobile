import '../../domain/entities/workout_plan.dart';
import '../../domain/repositories/workout_repository.dart';

class CompleteWorkoutUseCase {
  const CompleteWorkoutUseCase(this._repository);

  final WorkoutRepository _repository;

  Future<WorkoutPlan> call(WorkoutPlan workout) {
    return _repository.completeWorkout(workout);
  }
}
