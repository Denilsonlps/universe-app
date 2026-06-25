import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/repository_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

/// Mensageiro global para mostrar avisos em primeiro plano (foreground).
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Handler de mensagens em background (o SO exibe msgs com `notification`).
@pragma('vm:entry-point')
Future<void> _fcmBackgroundHandler(RemoteMessage message) async {}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);
    // Em primeiro plano o Android não mostra o balão sozinho — exibimos um SnackBar.
    FirebaseMessaging.onMessage.listen((m) {
      final n = m.notification;
      if (n == null) return;
      final msg = scaffoldMessengerKey.currentState;
      msg?.showSnackBar(SnackBar(
        content: Text(n.title != null ? '${n.title}\n${n.body ?? ''}'.trim() : (n.body ?? 'Nova notificação')),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ));
    });
  }

  runApp(const ProviderScope(child: UniverseApp()));
}

class UniverseApp extends ConsumerWidget {
  const UniverseApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    // Registra/limpa o token de push conforme o login.
    ref.listen(authStateProvider, (_, next) {
      final user = next.valueOrNull;
      if (user != null) {
        ref.read(pushServiceProvider).registerFor(user.id);
      } else {
        ref.read(pushServiceProvider).clear();
      }
    });

    return MaterialApp.router(
      title: 'Universe',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      routerConfig: router,
    );
  }
}
