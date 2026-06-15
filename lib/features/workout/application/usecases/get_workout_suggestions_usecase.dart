import '../../domain/entities/workout_plan.dart';
import '../../domain/repositories/workout_repository.dart';

class GetWorkoutSuggestionsUseCase {
  const GetWorkoutSuggestionsUseCase(this._repository);

  final WorkoutRepository _repository;

  Future<List<WorkoutPlan>> call() {
    return _repository.getWorkoutSuggestions();
  }
}
