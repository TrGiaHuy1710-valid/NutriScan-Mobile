class WorkoutPlan {
  const WorkoutPlan({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.difficulty,
    required this.equipment,
    required this.exercises,
    required this.estimatedCaloriesBurned,
    required this.tags,
    this.isScheduled = false,
    this.isCompleted = false,
    this.scheduledStartTime,
    this.scheduledEndTime,
  });

  final String id;
  final String title;
  final int durationMinutes;
  final String difficulty;
  final String equipment;
  final List<String> exercises;
  final int estimatedCaloriesBurned;
  final List<String> tags;
  final bool isScheduled;
  final bool isCompleted;
  final DateTime? scheduledStartTime;
  final DateTime? scheduledEndTime;

  WorkoutPlan copyWith({
    bool? isScheduled,
    bool? isCompleted,
    DateTime? scheduledStartTime,
    DateTime? scheduledEndTime,
  }) {
    return WorkoutPlan(
      id: id,
      title: title,
      durationMinutes: durationMinutes,
      difficulty: difficulty,
      equipment: equipment,
      exercises: exercises,
      estimatedCaloriesBurned: estimatedCaloriesBurned,
      tags: tags,
      isScheduled: isScheduled ?? this.isScheduled,
      isCompleted: isCompleted ?? this.isCompleted,
      scheduledStartTime: scheduledStartTime ?? this.scheduledStartTime,
      scheduledEndTime: scheduledEndTime ?? this.scheduledEndTime,
    );
  }
}
