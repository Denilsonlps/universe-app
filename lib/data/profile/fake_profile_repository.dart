import 'student_profile.dart';
import 'profile_repository.dart';

class FakeProfileRepository implements ProfileRepository {
  final Map<String, StudentProfile> _store = {};
  @override
  Future<StudentProfile?> get(String uid) async => _store[uid];
  @override
  Future<void> save(StudentProfile profile) async => _store[profile.uid] = profile;
}
