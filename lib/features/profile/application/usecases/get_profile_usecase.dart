import '../../domain/entities/user_health_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  const GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<UserHealthProfile> call() {
    return _repository.getProfile();
  }
}
