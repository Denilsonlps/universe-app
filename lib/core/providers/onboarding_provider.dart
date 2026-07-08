import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Se o onboarding (slides) já foi visto neste dispositivo.
/// `null` = ainda carregando do disco (não decidir a rota até assentar — evita
/// mostrar o onboarding por engano durante o arranque).
final onboardingSeenProvider = StateNotifierProvider<OnboardingSeenNotifier, bool?>((ref) => OnboardingSeenNotifier());

class OnboardingSeenNotifier extends StateNotifier<bool?> {
  OnboardingSeenNotifier() : super(null) { _load(); }
  static const _key = 'onboarding_seen';
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }
  Future<void> markSeen() async {
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
