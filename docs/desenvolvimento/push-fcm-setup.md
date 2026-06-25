# SP7b — Push real (FCM) e build Android: setup

A central de notificações (SP7a) já funciona. Esta etapa adiciona **push no aparelho**.
Há pré-requisitos de ambiente/infra que dependem de você. Siga na ordem.

## 0. Pré-requisitos (suas ações)
1. **Modo de Desenvolvedor do Windows** (necessário para o `flutter pub get` criar os
   symlinks de plugin): abra `ms-settings:developers` e ative. Sem isso, adicionar o
   `firebase_messaging` falha com *"Building with plugins requires symlink support"*.
2. **Plano Blaze** no Firebase (Cloud Functions exige billing): Console → Upgrade.
   Tem cota gratuita generosa; o uso do app é baixo.

## 1. Dependência do cliente
Em `pubspec.yaml`, abaixo de `firebase_storage`:
```yaml
  firebase_messaging: ^15.1.3
```
Depois: `flutter pub get`.

## 2. PushService (criar `lib/data/push/push_service.dart`)
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Registra o dispositivo no FCM e guarda o token em users/{uid}.
class PushService {
  PushService(this._db);
  final FirebaseFirestore _db;
  final _fm = FirebaseMessaging.instance;
  String? _uid;

  Future<void> registerFor(String uid) async {
    if (kIsWeb) return; // web push exige VAPID + service worker (ver seção 6)
    if (_uid == uid) return;
    try {
      final s = await _fm.requestPermission();
      if (s.authorizationStatus == AuthorizationStatus.denied) return;
      final token = await _fm.getToken();
      if (token != null) await _save(uid, token);
      _uid = uid;
      _fm.onTokenRefresh.listen((t) => _save(uid, t));
    } catch (e) {
      debugPrint('PushService: $e');
    }
  }

  Future<void> _save(String uid, String token) => _db.collection('users').doc(uid).set(
        {'fcmTokens': FieldValue.arrayUnion([token])}, SetOptions(merge: true));

  void clear() => _uid = null;
}
```

## 3. Provider (em `lib/core/providers/repository_provider.dart`)
```dart
import '../../data/push/push_service.dart';
final pushServiceProvider = Provider<PushService>((ref) => PushService(FirebaseFirestore.instance));
```

## 4. Wiring (em `lib/main.dart`)
```dart
// topo do arquivo
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'core/providers/repository_provider.dart';
import 'core/providers/auth_provider.dart';

@pragma('vm:entry-point')
Future<void> _fcmBg(RemoteMessage m) async {} // OS exibe msgs com 'notification'

// dentro de main(), após Firebase.initializeApp:
if (!kIsWeb) FirebaseMessaging.onBackgroundMessage(_fcmBg);

// dentro do build de UniverseApp (ConsumerWidget), antes do return:
ref.listen(authStateProvider, (_, next) {
  final u = next.valueOrNull;
  if (u != null) { ref.read(pushServiceProvider).registerFor(u.id); }
  else { ref.read(pushServiceProvider).clear(); }
});
```
> Em primeiro plano o Android não exibe o balão automaticamente. A central no app já
> atualiza ao vivo (stream do Firestore). Para heads-up em foreground, adicionar
> `flutter_local_notifications` depois (opcional).

## 5. Cloud Function (já versionada em `functions/`)
`functions/index.js` dispara no `onCreate` de `notifications/{id}` e envia FCM aos tokens
do curso-alvo (ou a todos, se `targetCourse` for null), limpando tokens inválidos.
```bash
cd functions && npm install && cd ..
firebase deploy --only functions   # requer Blaze
```

## 6. Build Android (APK para testar no celular)
```bash
flutter build apk --release
# saída: build/app/outputs/flutter-apk/app-release.apk
```
Envie o APK ao colega (ou use `flutter install`). O Android 13+ pede permissão de
notificação na primeira execução (tratado por `requestPermission`).

## 7. (Opcional, depois) Push no navegador/PWA
- Gerar **chave VAPID** no Console (Cloud Messaging → Web Push certificates).
- Criar `web/firebase-messaging-sw.js` e passar `vapidKey` no `getToken` (remover o
  guard `kIsWeb`). iOS só recebe push como PWA instalado (iOS 16.4+).

## Verificação de ponta a ponta
1. Logar no app Android (gera token em `users/{uid}.fcmTokens`).
2. Admin aprova uma vaga do curso do aluno → nasce `notifications/{id}`.
3. A function envia o push; o aparelho recebe; tocar abre a rota.
