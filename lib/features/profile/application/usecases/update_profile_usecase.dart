import '../../domain/entities/user_health_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<void> call(UserHealthProfile profile) {
    return _repository.updateProfile(profile);
  }
}
