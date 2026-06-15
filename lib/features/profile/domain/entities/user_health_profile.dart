class UserHealthProfile {
  const UserHealthProfile({
    required this.name,
    required this.ageRange,
    required this.bodyStatus,
    required this.healthGoal,
    required this.activityLevel,
    required this.workoutLevel,
    required this.foodPreferences,
    required this.avoidList,
    required this.preferredWorkoutDuration,
    required this.availableEquipment,
    required this.calendarConnectionStatus,
    required this.recommendationTags,
  });

  final String name;
  final String ageRange;
  final String bodyStatus;
  final String healthGoal;
  final String activityLevel;
  final String workoutLevel;
  final List<String> foodPreferences;
  final List<String> avoidList;
  final String preferredWorkoutDuration;
  final List<String> availableEquipment;
  final String calendarConnectionStatus;
  final List<String> recommendationTags;
}
