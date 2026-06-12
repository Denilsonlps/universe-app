import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth/auth_repository.dart';
import '../../data/auth/firebase_auth_repository.dart';
import '../../data/models/app_user.dart';

/// Repositório de auth. Sobrescrito por FakeAuthRepository nos testes.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(FirebaseAuth.instance);
});

/// Estado de autenticação como stream de AppUser?.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authState();
});
