import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/universe_repository.dart';
import '../../data/repositories/mock_universe_repository.dart';

/// Conteúdo do app. Sobrescrito nos testes; trocar por FirestoreUniverseRepository depois.
final universeRepositoryProvider =
    Provider<UniverseRepository>((ref) => MockUniverseRepository());
