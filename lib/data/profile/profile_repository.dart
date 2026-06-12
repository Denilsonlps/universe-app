import 'student_profile.dart';

abstract interface class ProfileRepository {
  Future<StudentProfile?> get(String uid);
  Future<void> save(StudentProfile profile);
}
