import '../entities/user_health_profile.dart';

abstract class ProfileRepository {
  Future<UserHealthProfile> getProfile();
  Future<void> updateProfile(UserHealthProfile profile);
}
