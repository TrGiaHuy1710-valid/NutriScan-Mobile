import '../../domain/entities/workout_plan.dart';
import '../../domain/repositories/workout_repository.dart';

class GetScheduledWorkoutUseCase {
  const GetScheduledWorkoutUseCase(this._repository);

  final WorkoutRepository _repository;

  Future<WorkoutPlan?> call() {
    return _repository.getScheduledWorkoutToday();
  }
}
