import '../../../../core/persistence/local_json_store.dart';
import '../../../calendar/domain/entities/free_time_slot.dart';
import '../../domain/entities/workout_plan.dart';
import '../../domain/repositories/workout_repository.dart';
import '../workout_plan_json.dart';

class FakeWorkoutRepository implements WorkoutRepository {
  FakeWorkoutRepository({LocalJsonStore? store}) : _store = store;

  static const _scheduledWorkoutKey = 'scheduledWorkout';

  final LocalJsonStore? _store;
  WorkoutPlan? _scheduledWorkout;
  bool _hasLoadedScheduledWorkout = false;

  @override
  Future<List<WorkoutPlan>> getWorkoutSuggestions() async {
    return const [
      WorkoutPlan(
        id: 'workout_15m_stretch',
        title: '15-Min Quick Stretch',
        durationMinutes: 15,
        difficulty: 'Beginner',
        equipment: 'None',
        estimatedCaloriesBurned: 40,
        tags: ['Stretching', 'Short', 'Recovery'],
        exercises: [
          'Warm Up (3 min)',
          'Stretching (10 min)',
          'Cool Down (2 min)',
        ],
      ),
      WorkoutPlan(
        id: 'workout_15m_cardio',
        title: '15-Min Express Cardio',
        durationMinutes: 15,
        difficulty: 'Intermediate',
        equipment: 'None',
        estimatedCaloriesBurned: 110,
        tags: ['HIIT', 'Cardio', 'Express'],
        exercises: [
          'Warm Up (2 min)',
          'HIIT Cardio (11 min)',
          'Cool Down (2 min)',
        ],
      ),
      WorkoutPlan(
        id: 'workout_30m_stretch',
        title: '30-Min Cardio & Stretch',
        durationMinutes: 30,
        difficulty: 'Beginner',
        equipment: 'None',
        estimatedCaloriesBurned: 150,
        tags: ['Cardio', 'Mobility', 'Stretching'],
        exercises: [
          'Warm Up (5 min)',
          'Cardio (15 min)',
          'Stretching (10 min)',
        ],
      ),
      WorkoutPlan(
        id: 'workout_30m_strength',
        title: '30-Min Power Pilates',
        durationMinutes: 30,
        difficulty: 'Intermediate',
        equipment: 'Mat',
        estimatedCaloriesBurned: 160,
        tags: ['Core', 'Pilates', 'Strength'],
        exercises: [
          'Warm Up (5 min)',
          'Pilates Core (20 min)',
          'Cool Down (5 min)',
        ],
      ),
      WorkoutPlan(
        id: 'workout_45m_strength',
        title: '45-Min Full Body Strength',
        durationMinutes: 45,
        difficulty: 'Intermediate',
        equipment: 'Dumbbells',
        estimatedCaloriesBurned: 280,
        tags: ['Strength', 'Full Body', 'Dumbbells'],
        exercises: [
          'Warm Up (8 min)',
          'Strength Training (27 min)',
          'Stretching (10 min)',
        ],
      ),
      WorkoutPlan(
        id: 'workout_45m_cardio',
        title: '45-Min Cardio Endurance',
        durationMinutes: 45,
        difficulty: 'Advanced',
        equipment: 'None',
        estimatedCaloriesBurned: 320,
        tags: ['Cardio', 'Endurance', 'HIIT'],
        exercises: [
          'Warm Up (5 min)',
          'Cardio (35 min)',
          'Cool Down (5 min)',
        ],
      ),
      WorkoutPlan(
        id: 'workout_60m_classic',
        title: '60-Min Classic Gym Routine',
        durationMinutes: 60,
        difficulty: 'Advanced',
        equipment: 'Full Gym',
        estimatedCaloriesBurned: 450,
        tags: ['Strength', 'Cardio', 'Gym'],
        exercises: [
          'Warm Up (10 min)',
          'Strength Training (30 min)',
          'Cardio (15 min)',
          'Cool Down (5 min)',
        ],
      ),
      WorkoutPlan(
        id: 'workout_60m_yoga',
        title: '60-Min Yoga Flow & Core',
        durationMinutes: 60,
        difficulty: 'Intermediate',
        equipment: 'Yoga Mat',
        estimatedCaloriesBurned: 220,
        tags: ['Yoga', 'Core', 'Mindfulness'],
        exercises: [
          'Warm Up (10 min)',
          'Yoga Flow (35 min)',
          'Core Focus (10 min)',
          'Cool Down (5 min)',
        ],
      ),
      WorkoutPlan(
        id: 'workout_90m_ultimate',
        title: '90-Min Ultimate Athlete Session',
        durationMinutes: 90,
        difficulty: 'Advanced',
        equipment: 'Full Gym',
        estimatedCaloriesBurned: 700,
        tags: ['Strength', 'HIIT', 'Athlete'],
        exercises: [
          'Warm Up (15 min)',
          'Strength Training (45 min)',
          'Cardio (20 min)',
          'Cool Down (10 min)',
        ],
      ),
      WorkoutPlan(
        id: 'workout_90m_recovery',
        title: '90-Min Deep Recovery & Yoga',
        durationMinutes: 90,
        difficulty: 'Beginner',
        equipment: 'Foam Roller',
        estimatedCaloriesBurned: 250,
        tags: ['Recovery', 'Stretching', 'Meditation'],
        exercises: [
          'Warm Up (10 min)',
          'Deep Stretching (60 min)',
          'Meditation (20 min)',
        ],
      ),
    ];
  }

  @override
  Future<WorkoutPlan?> getScheduledWorkoutToday() async {
    await _ensureScheduledWorkoutLoaded();
    return _scheduledWorkout;
  }

  @override
  Future<WorkoutPlan> scheduleWorkout({
    required WorkoutPlan workout,
    required FreeTimeSlot slot,
  }) async {
    await _ensureScheduledWorkoutLoaded();
    final scheduledEnd = slot.startTime.add(
      Duration(minutes: workout.durationMinutes),
    );
    _scheduledWorkout = workout.copyWith(
      isScheduled: true,
      scheduledStartTime: slot.startTime,
      scheduledEndTime: scheduledEnd.isAfter(slot.endTime)
          ? slot.endTime
          : scheduledEnd,
    );
    await _persistScheduledWorkout();
    return _scheduledWorkout!;
  }

  @override
  Future<WorkoutPlan> completeWorkout(WorkoutPlan workout) async {
    await _ensureScheduledWorkoutLoaded();
    _scheduledWorkout = workout.copyWith(isCompleted: true);
    await _persistScheduledWorkout();
    return _scheduledWorkout!;
  }

  Future<void> _ensureScheduledWorkoutLoaded() async {
    if (_hasLoadedScheduledWorkout) {
      return;
    }

    final storedWorkout = await _store?.readMap(_scheduledWorkoutKey);
    _scheduledWorkout = storedWorkout == null
        ? null
        : workoutPlanFromJson(storedWorkout);
    _hasLoadedScheduledWorkout = true;
  }

  Future<void> _persistScheduledWorkout() async {
    await _store?.writeMap(_scheduledWorkoutKey, _scheduledWorkout?.toJson());
  }
}
