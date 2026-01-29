import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/profile_model.dart';

part 'profile_provider.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  @override
  Future<UserProfile> build() async {
    final repo = await _getRepository();
    return repo.getProfile();
  }

  Future<ProfileRepository> _getRepository() async {
    final prefs = await SharedPreferences.getInstance();
    return ProfileRepository(prefs);
  }

  Future<void> updateProfile(UserProfile profile) async {
    final repo = await _getRepository();
    await repo.saveProfile(profile);
    state = AsyncValue.data(profile);
  }
}
