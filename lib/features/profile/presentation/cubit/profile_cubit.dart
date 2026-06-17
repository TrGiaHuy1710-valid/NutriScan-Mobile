import 'package:flutter/foundation.dart';

import '../../application/usecases/get_profile_usecase.dart';
import '../../application/usecases/update_profile_usecase.dart';
import '../../domain/entities/user_health_profile.dart';
import 'profile_state.dart';

class ProfileCubit extends ChangeNotifier {
  ProfileCubit({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
  }) : _getProfileUseCase = getProfileUseCase,
       _updateProfileUseCase = updateProfileUseCase;

  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;

  ProfileState _state = ProfileState.initial();

  ProfileState get state => _state;

  Future<void> loadProfile() async {
    _emit(_state.copyWith(status: ProfileStatus.loading));
    try {
      final profile = await _getProfileUseCase();
      _emit(
        ProfileState(
          status: ProfileStatus.loaded,
          profile: profile,
        ),
      );
    } catch (_) {
      _emit(
        _state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'Unable to load profile.',
        ),
      );
    }
  }

  Future<void> updateProfile({
    required String name,
    required double weight,
    required double height,
    required int age,
    required String goal,
    required String restrictions,
  }) async {
    try {
      // Auto re-calculate calorie/macro targets based on health goal
      final baseline = (10 * weight + 6.25 * height - 5 * age + 5).toInt();
      int targetCal;
      switch (goal) {
        case 'Giảm cân':
          targetCal = (baseline * 0.85).toInt();
          break;
        case 'Tăng cân':
          targetCal = (baseline * 1.15).toInt();
          break;
        case 'Giữ cân':
        default:
          targetCal = baseline;
          break;
      }

      final targetProtein = (weight * 2.0).toInt().clamp(60, 200);
      final targetFat = (targetCal * 0.25 / 9.0).toInt().clamp(40, 100);
      final targetCarbs = ((targetCal - (targetProtein * 4) - (targetFat * 9)) ~/ 4).clamp(100, 400);

      final current = _state.profile ?? const UserHealthProfile(name: 'Huy Nguyễn');
      final updated = current.copyWith(
        name: name,
        weight: weight,
        height: height,
        age: age,
        healthGoal: goal,
        dietaryRestrictions: restrictions,
        targetCalories: targetCal,
        targetProtein: targetProtein,
        targetCarbs: targetCarbs,
        targetFat: targetFat,
      );

      await _updateProfileUseCase(updated);
      _emit(ProfileState(status: ProfileStatus.loaded, profile: updated));
    } catch (_) {
      _emit(
        _state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'Unable to update profile.',
        ),
      );
    }
  }

  Future<void> updateCustomTargets({
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
  }) async {
    try {
      final current = _state.profile;
      if (current == null) return;
      final updated = current.copyWith(
        targetCalories: calories,
        targetProtein: protein,
        targetCarbs: carbs,
        targetFat: fat,
      );
      await _updateProfileUseCase(updated);
      _emit(ProfileState(status: ProfileStatus.loaded, profile: updated));
    } catch (_) {
      _emit(
        _state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'Unable to update custom targets.',
        ),
      );
    }
  }

  void _emit(ProfileState state) {
    _state = state;
    notifyListeners();
  }
}
