import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_profile.dart';
import 'profile_repository.dart';

class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository(this._db);
  final FirebaseFirestore _db;

  @override
  Future<StudentProfile?> get(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data();
    return data == null ? null : StudentProfile.fromMap(uid, data);
  }

  @override
  Future<void> save(StudentProfile profile) async =>
      _db.collection('users').doc(profile.uid).set(profile.toMap(), SetOptions(merge: true));
}
