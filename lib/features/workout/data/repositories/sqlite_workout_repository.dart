import '../../../../core/persistence/app_database.dart';
import '../../../calendar/domain/entities/free_time_slot.dart';
import '../../domain/entities/workout_plan.dart';
import '../../domain/repositories/workout_repository.dart';
import 'fake_workout_repository.dart';

class SqliteWorkoutRepository implements WorkoutRepository {
  SqliteWorkoutRepository(this._database);

  final AppDatabase _database;
  final FakeWorkoutRepository _suggestionSource = FakeWorkoutRepository();

  @override
  Future<List<WorkoutPlan>> getWorkoutSuggestions() {
    return _suggestionSource.getWorkoutSuggestions();
  }

  @override
  Future<WorkoutPlan?> getScheduledWorkoutToday() async {
    final db = await _database.database;
    final rows = await db.query('scheduled_workout', limit: 1);
    if (rows.isEmpty) {
      return null;
    }
    return _workoutFromRow(rows.first);
  }

  @override
  Future<WorkoutPlan> scheduleWorkout({
    required WorkoutPlan workout,
    required FreeTimeSlot slot,
  }) async {
    final scheduledEnd = slot.startTime.add(
      Duration(minutes: workout.durationMinutes),
    );
    final scheduledWorkout = workout.copyWith(
      isScheduled: true,
      isCompleted: false,
      scheduledStartTime: slot.startTime,
      scheduledEndTime: scheduledEnd.isAfter(slot.endTime)
          ? slot.endTime
          : scheduledEnd,
    );

    final db = await _database.database;
    await db.delete('scheduled_workout');
    await db.insert('scheduled_workout', _workoutToRow(scheduledWorkout));
    return scheduledWorkout;
  }

  @override
  Future<WorkoutPlan> completeWorkout(WorkoutPlan workout) async {
    final completedWorkout = workout.copyWith(isCompleted: true);
    final db = await _database.database;
    await db.delete('scheduled_workout');
    await db.insert('scheduled_workout', _workoutToRow(completedWorkout));
    return completedWorkout;
  }

  @override
  Future<void> clearAllWorkouts() async {
    final db = await _database.database;
    await db.delete('scheduled_workout');
  }

  Map<String, Object?> _workoutToRow(WorkoutPlan workout) {
    return {
      'id': workout.id,
      'title': workout.title,
      'duration_minutes': workout.durationMinutes,
      'difficulty': workout.difficulty,
      'equipment': workout.equipment,
      'exercises': workout.exercises.join('|'),
      'estimated_calories_burned': workout.estimatedCaloriesBurned,
      'tags': workout.tags.join(','),
      'is_scheduled': workout.isScheduled ? 1 : 0,
      'is_completed': workout.isCompleted ? 1 : 0,
      'scheduled_start_time': workout.scheduledStartTime?.toIso8601String(),
      'scheduled_end_time': workout.scheduledEndTime?.toIso8601String(),
    };
  }

  WorkoutPlan _workoutFromRow(Map<String, Object?> row) {
    return WorkoutPlan(
      id: row['id'] as String,
      title: row['title'] as String,
      durationMinutes: row['duration_minutes'] as int,
      difficulty: row['difficulty'] as String,
      equipment: row['equipment'] as String,
      exercises: ((row['exercises'] as String?) ?? '')
          .split('|')
          .where((exercise) => exercise.isNotEmpty)
          .toList(),
      estimatedCaloriesBurned: row['estimated_calories_burned'] as int,
      tags: ((row['tags'] as String?) ?? '')
          .split(',')
          .where((tag) => tag.isNotEmpty)
          .toList(),
      isScheduled: row['is_scheduled'] == 1,
      isCompleted: row['is_completed'] == 1,
      scheduledStartTime: DateTime.tryParse(
        row['scheduled_start_time'] as String? ?? '',
      ),
      scheduledEndTime: DateTime.tryParse(
        row['scheduled_end_time'] as String? ?? '',
      ),
    );
  }
}
