import '../domain/entities/user_health_profile.dart';

const mockUserHealthProfile = UserHealthProfile(
  name: 'Huy Nguyen',
  weight: 60.0,
  height: 165.0,
  age: 22,
  healthGoal: 'Build healthy habits',
  activityLevel: 'Lightly active',
  workoutLevel: 'Beginner',
  foodPreferences: ['Simple home meals', 'High protein options'],
  dietaryRestrictions: 'Shellfish',
  preferredWorkoutDuration: '15 minutes',
  availableEquipment: ['None'],
  calendarConnectionStatus: 'Not connected - placeholder for later',
  recommendationTags: [
    'balanced',
    'home_cooking',
    'high_protein',
    'quick_meal',
  ],
);
