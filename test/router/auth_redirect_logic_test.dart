import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/core/router/app_router.dart';
import 'package:universe_app/data/models/app_user.dart';

void main() {
  const loading = AsyncValue<AppUser?>.loading();
  const loggedOut = AsyncValue<AppUser?>.data(null);
  const loggedIn = AsyncValue<AppUser?>.data(AppUser(id: 'u1', name: 'Ana', email: 'a@b.com'));

  group('authRedirect', () {
    test('auth ainda carregando → espera no splash', () {
      expect(authRedirect(loading, true, '/splash'), '/splash');
      expect(authRedirect(loading, false, '/home'), '/splash');
    });

    test('onboarding ainda carregando (null) → espera no splash (corrige a corrida)', () {
      // Deslogado + prefs não carregou: NÃO pode mandar pro onboarding ainda.
      expect(authRedirect(loggedOut, null, '/splash'), '/splash');
      expect(authRedirect(loggedIn, null, '/splash'), '/splash');
    });

    test('deslogado e já viu o onboarding → login', () {
      expect(authRedirect(loggedOut, true, '/splash'), '/login');
    });

    test('deslogado e nunca viu o onboarding → onboarding', () {
      expect(authRedirect(loggedOut, false, '/splash'), '/onboarding');
    });

    test('deslogado já nas rotas de auth → não redireciona (sem loop)', () {
      expect(authRedirect(loggedOut, true, '/login'), isNull);
      expect(authRedirect(loggedOut, false, '/onboarding'), isNull);
      expect(authRedirect(loggedOut, true, '/register'), isNull);
    });

    test('logado no splash/auth → vai pra home', () {
      expect(authRedirect(loggedIn, true, '/splash'), '/home');
      expect(authRedirect(loggedIn, true, '/login'), '/home');
      expect(authRedirect(loggedIn, false, '/onboarding'), '/home');
    });

    test('logado numa rota normal → fica onde está', () {
      expect(authRedirect(loggedIn, true, '/home'), isNull);
      expect(authRedirect(loggedIn, true, '/cursos'), isNull);
    });
  });
}
