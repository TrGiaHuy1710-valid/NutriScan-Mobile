import '../../domain/entities/user_health_profile.dart';

enum ProfileStatus { initial, loading, loaded, failure }

class ProfileState {
  const ProfileState({
    required this.status,
    this.profile,
    this.errorMessage,
  });

  factory ProfileState.initial() {
    return const ProfileState(status: ProfileStatus.initial);
  }

  final ProfileStatus status;
  final UserHealthProfile? profile;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    UserHealthProfile? profile,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
