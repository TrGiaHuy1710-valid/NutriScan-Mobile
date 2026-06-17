class UserHealthProfile {
  const UserHealthProfile({
    required this.name,
    this.weight = 60.0,
    this.height = 165.0,
    this.age = 22,
    this.healthGoal = 'Giữ cân',
    this.dietaryRestrictions = '',
    this.targetCalories = 2000,
    this.targetProtein = 120,
    this.targetCarbs = 230,
    this.targetFat = 67,
    this.activityLevel = 'Lightly active',
    this.workoutLevel = 'Beginner',
    this.foodPreferences = const ['Simple home meals', 'High protein options'],
    this.preferredWorkoutDuration = '15 minutes',
    this.availableEquipment = const ['None'],
    this.calendarConnectionStatus = 'Not connected - placeholder for later',
    this.recommendationTags = const ['balanced', 'home_cooking', 'high_protein', 'quick_meal'],
  });

  final String name;
  final double weight;
  final double height;
  final int age;
  final String healthGoal;
  final String dietaryRestrictions;
  final int targetCalories;
  final int targetProtein;
  final int targetCarbs;
  final int targetFat;
  
  final String activityLevel;
  final String workoutLevel;
  final List<String> foodPreferences;
  final String preferredWorkoutDuration;
  final List<String> availableEquipment;
  final String calendarConnectionStatus;
  final List<String> recommendationTags;

  String get ageRange {
    if (age < 18) return '<18';
    if (age <= 24) return '18-24';
    if (age <= 34) return '25-34';
    if (age <= 44) return '35-44';
    return '45+';
  }

  String get bodyStatus => 'Cân nặng: ${weight}kg, Chiều cao: ${height}cm';

  List<String> get avoidList {
    if (dietaryRestrictions.trim().isEmpty) {
      return const [];
    }
    return dietaryRestrictions
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  UserHealthProfile copyWith({
    String? name,
    double? weight,
    double? height,
    int? age,
    String? healthGoal,
    String? dietaryRestrictions,
    int? targetCalories,
    int? targetProtein,
    int? targetCarbs,
    int? targetFat,
    String? activityLevel,
    String? workoutLevel,
    List<String>? foodPreferences,
    String? preferredWorkoutDuration,
    List<String>? availableEquipment,
    String? calendarConnectionStatus,
    List<String>? recommendationTags,
  }) {
    return UserHealthProfile(
      name: name ?? this.name,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
      healthGoal: healthGoal ?? this.healthGoal,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProtein: targetProtein ?? this.targetProtein,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      targetFat: targetFat ?? this.targetFat,
      activityLevel: activityLevel ?? this.activityLevel,
      workoutLevel: workoutLevel ?? this.workoutLevel,
      foodPreferences: foodPreferences ?? this.foodPreferences,
      preferredWorkoutDuration: preferredWorkoutDuration ?? this.preferredWorkoutDuration,
      availableEquipment: availableEquipment ?? this.availableEquipment,
      calendarConnectionStatus: calendarConnectionStatus ?? this.calendarConnectionStatus,
      recommendationTags: recommendationTags ?? this.recommendationTags,
    );
  }
}
