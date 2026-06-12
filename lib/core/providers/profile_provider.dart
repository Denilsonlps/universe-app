import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/profile/profile_repository.dart';
import '../../data/profile/firestore_profile_repository.dart';
import '../../data/profile/student_profile.dart';
import 'auth_provider.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) =>
    FirestoreProfileRepository(FirebaseFirestore.instance));

/// Perfil do usuário autenticado (null se deslogado ou sem perfil ainda).
final currentProfileProvider = FutureProvider<StudentProfile?>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return null;
  return ref.read(profileRepositoryProvider).get(user.id);
});
