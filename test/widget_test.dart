import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universe_app/core/providers/auth_provider.dart';
import 'package:universe_app/core/providers/repository_provider.dart';
import 'package:universe_app/core/providers/theme_provider.dart';
import 'package:universe_app/core/router/app_router.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/data/auth/fake_auth_repository.dart';
import 'package:universe_app/data/repositories/fake_universe_repository.dart';

void main() {
  testWidgets('deslogado, o app abre no onboarding', (t) async {
    SharedPreferences.setMockInitialValues({});
    final fake = FakeAuthRepository();
    await t.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(fake),
        universeRepositoryProvider.overrideWith((ref) => FakeUniverseRepository()),
      ],
      child: Consumer(builder: (c, ref, _) {
        ref.watch(themeModeProvider);
        return MaterialApp.router(theme: AppTheme.light, routerConfig: ref.watch(routerProvider));
      }),
    ));
    await t.pumpAndSettle();
    expect(find.text('Próximo'), findsOneWidget);
  });
}
