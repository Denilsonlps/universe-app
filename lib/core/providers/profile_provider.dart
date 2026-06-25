import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/courses.dart';
import '../../data/profile/profile_repository.dart';
import '../../data/profile/firestore_profile_repository.dart';
import '../../data/profile/student_profile.dart';
import 'auth_provider.dart';
import 'repository_provider.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) =>
    FirestoreProfileRepository(FirebaseFirestore.instance));

/// Perfil do usuário autenticado (null se deslogado ou sem perfil ainda).
final currentProfileProvider = FutureProvider<StudentProfile?>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return null;
  return ref.read(profileRepositoryProvider).get(user.id);
});

/// True se o usuário atual tem papel admin (Setor de Estágios).
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(currentProfileProvider).valueOrNull?.role == 'admin';
});

/// Quantidade de notificações não-lidas para o usuário atual (respeita o filtro
/// "só o meu curso" e a marca `lastSeenNotificationsAt`).
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifs = ref.watch(notificationsProvider).valueOrNull ?? const [];
  final profile = ref.watch(currentProfileProvider).valueOrNull;
  final meuCursoCurto = profile?.course == null ? null : courseShort(profile!.course!);
  final lastSeen = profile?.lastSeenNotificationsAt;
  final onlyMine = profile?.onlyMyCourse ?? false;
  return notifs.where((n) {
    if (onlyMine && !n.matchesCourse(meuCursoCurto)) return false;
    if (lastSeen != null && !n.createdAt.isAfter(lastSeen)) return false;
    return true;
  }).length;
});
