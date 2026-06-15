import '../domain/entities/workout_plan.dart';

extension WorkoutPlanJson on WorkoutPlan {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'durationMinutes': durationMinutes,
      'difficulty': difficulty,
      'equipment': equipment,
      'exercises': exercises,
      'estimatedCaloriesBurned': estimatedCaloriesBurned,
      'tags': tags,
      'isScheduled': isScheduled,
      'isCompleted': isCompleted,
      'scheduledStartTime': scheduledStartTime?.toIso8601String(),
      'scheduledEndTime': scheduledEndTime?.toIso8601String(),
    };
  }
}

WorkoutPlan workoutPlanFromJson(Map<String, dynamic> json) {
  return WorkoutPlan(
    id: json['id'] as String? ?? 'workout_local',
    title: json['title'] as String? ?? 'Saved workout',
    durationMinutes: json['durationMinutes'] as int? ?? 10,
    difficulty: json['difficulty'] as String? ?? 'Beginner',
    equipment: json['equipment'] as String? ?? 'None',
    exercises:
        (json['exercises'] as List?)?.whereType<String>().toList() ?? const [],
    estimatedCaloriesBurned: json['estimatedCaloriesBurned'] as int? ?? 0,
    tags: (json['tags'] as List?)?.whereType<String>().toList() ?? const [],
    isScheduled: json['isScheduled'] as bool? ?? false,
    isCompleted: json['isCompleted'] as bool? ?? false,
    scheduledStartTime: DateTime.tryParse(
      json['scheduledStartTime'] as String? ?? '',
    ),
    scheduledEndTime: DateTime.tryParse(
      json['scheduledEndTime'] as String? ?? '',
    ),
  );
}
