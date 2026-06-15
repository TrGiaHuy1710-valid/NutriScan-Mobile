import 'workout_plan.dart';

class DailyWorkoutPlan {
  const DailyWorkoutPlan({
    required this.dayName,
    required this.workoutName,
    required this.date,
    this.isRestDay = false,
    this.scheduledWorkout,
  });

  final String dayName;
  final String workoutName;
  final DateTime date;
  final bool isRestDay;
  final WorkoutPlan? scheduledWorkout;
}
