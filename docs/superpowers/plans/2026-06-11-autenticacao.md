# Plano 2 — Autenticação (Universe)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Login e cadastro reais com Firebase Auth, com o app protegido por estado de autenticação (splash → onboarding/login → home).

**Architecture:** A UI depende de uma interface `AuthRepository` (não do Firebase diretamente). `FirebaseAuthRepository` implementa via `firebase_auth`; `FakeAuthRepository` permite testes sem rede. Riverpod expõe `authStateProvider` (stream de `AppUser?`). O `go_router` redireciona com base nesse estado. Isso concretiza a decisão "híbrida" da spec (auth real, resto mock depois).

**Tech Stack:** firebase_core, firebase_auth, flutter_riverpod, go_router. Reusa o design system e o chrome do Plano 1.

**Spec:** `docs/superpowers/specs/2026-06-11-universe-rebuild-design.md` §7 (Auth) e §4 (papéis). **Design fonte:** `design_reference/project/universe/screens-auth.jsx`.

**Pré-requisitos já prontos (Plano 1):** `context.c`/`AppColorsX`, `AppButton`, `AppCard`, `IconTile`/`appIcon`, `PageShell`, navegação com `ShellRoute` (4 abas) em `lib/core/router/app_router.dart`, `main.dart` com `ProviderScope`+`MaterialApp.router`.

---

## Estrutura de arquivos (Plano 2)

```
lib/
  shared/widgets/app_field.dart        AppField + PasswordField (faltavam no DS)
  data/
    models/app_user.dart               AppUser (id, name, email, role)
    auth/auth_repository.dart          interface AuthRepository + AuthException + AuthRole
    auth/fake_auth_repository.dart     impl em memória (dev/testes)
    auth/firebase_auth_repository.dart impl real (firebase_auth)
  core/providers/auth_provider.dart    authRepositoryProvider + authStateProvider
  core/router/app_router.dart          MODIFICA: vira routerProvider com redirect por auth
  features/auth/screens/
    splash_screen.dart
    onboarding_screen.dart
    login_screen.dart
    register_screen.dart
  main.dart                            MODIFICA: Firebase.initializeApp + routerProvider
test/
  widgets/app_field_test.dart
  data/fake_auth_repository_test.dart
  features/login_screen_test.dart
  router/auth_redirect_test.dart
```

---

### Task 1: AppField + PasswordField (complementa o design system)

**Files:**
- Create: `lib/shared/widgets/app_field.dart`
- Test: `test/widgets/app_field_test.dart`

- [ ] **Step 1: Criar o widget**

`lib/shared/widgets/app_field.dart`:
```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'icon_tile.dart';

class AppField extends StatefulWidget {
  final String? label, hint, icon, error;
  final String value;
  final ValueChanged<String> onChanged;
  final bool obscure, valid;
  final Widget? trailing;
  final TextInputType? keyboardType;
  const AppField({
    super.key, this.label, this.hint, this.icon, this.error,
    required this.value, required this.onChanged,
    this.obscure = false, this.valid = false, this.trailing, this.keyboardType,
  });

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  late final TextEditingController _ctrl = TextEditingController(text: widget.value);
  bool _focus = false;

  @override
  void didUpdateWidget(AppField old) {
    super.didUpdateWidget(old);
    if (widget.value != _ctrl.text) _ctrl.text = widget.value;
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final border = widget.error != null
        ? c.error
        : _focus ? c.green500 : widget.valid ? c.green400 : c.line;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (widget.label != null)
        Padding(
          padding: const EdgeInsets.only(left: 3, bottom: 7),
          child: Text(widget.label!, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.ink2)),
        ),
      Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: c.card, borderRadius: BorderRadius.circular(13),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Row(children: [
          if (widget.icon != null) ...[
            Icon(appIcon(widget.icon!), size: 19, color: _focus ? c.green600 : c.ink3),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Focus(
              onFocusChange: (f) => setState(() => _focus = f),
              child: TextField(
                controller: _ctrl,
                onChanged: widget.onChanged,
                obscureText: widget.obscure,
                keyboardType: widget.keyboardType,
                style: TextStyle(fontSize: 15, color: c.ink, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  isCollapsed: true, border: InputBorder.none,
                  hintText: widget.hint,
                  hintStyle: TextStyle(fontSize: 14, color: c.ink3, fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ),
          if (widget.valid && widget.trailing == null)
            Icon(Icons.check, size: 18, color: c.green500),
          if (widget.trailing != null) widget.trailing!,
        ]),
      ),
      if (widget.error != null)
        Padding(
          padding: const EdgeInsets.only(left: 3, top: 6),
          child: Text(widget.error!, style: TextStyle(fontSize: 11.5, color: c.error, fontWeight: FontWeight.w600)),
        ),
    ]);
  }
}

class PasswordField extends StatefulWidget {
  final String? label, hint, error;
  final String value;
  final ValueChanged<String> onChanged;
  final bool valid;
  const PasswordField({super.key, this.label, this.hint, this.error, required this.value, required this.onChanged, this.valid = false});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _show = false;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AppField(
      label: widget.label, hint: widget.hint, error: widget.error, icon: 'shield',
      value: widget.value, onChanged: widget.onChanged, valid: widget.valid, obscure: !_show,
      trailing: InkWell(
        onTap: () => setState(() => _show = !_show),
        child: Icon(_show ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 19, color: c.ink3),
      ),
    );
  }
}
```

- [ ] **Step 2: Teste de fumaça**

`test/widgets/app_field_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/shared/widgets/app_field.dart';

void main() {
  testWidgets('AppField emite onChanged e mostra erro', (t) async {
    String v = '';
    await t.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: AppField(label: 'E-mail', icon: 'mail', value: v, error: 'inválido', onChanged: (x) => v = x)),
    ));
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('inválido'), findsOneWidget);
    await t.enterText(find.byType(TextField), 'a@b.com');
    expect(v, 'a@b.com');
  });

  testWidgets('PasswordField alterna visibilidade', (t) async {
    await t.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: PasswordField(label: 'Senha', value: 'x', onChanged: (_) {})),
    ));
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    await t.tap(find.byIcon(Icons.visibility_outlined));
    await t.pump();
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });
}
```

- [ ] **Step 3: Rodar `flutter test test/widgets/app_field_test.dart`** — esperado PASS. `flutter analyze lib/shared/widgets/app_field.dart` sem erros.
- [ ] **Step 4: Commit** — `git add lib/shared/widgets/app_field.dart test/widgets/app_field_test.dart && git commit -m "feat(ui): AppField e PasswordField"`

---

### Task 2: Modelo `AppUser`

**Files:**
- Create: `lib/data/models/app_user.dart`

- [ ] **Step 1: Criar o modelo**

`lib/data/models/app_user.dart`:
```dart
/// Papel do usuário. `admin` = Setor de Estágios (cadastra vagas — ver spec §4).
enum AuthRole { student, admin }

class AppUser {
  final String id;
  final String name;
  final String email;
  final AuthRole role;

  const AppUser({required this.id, required this.name, required this.email, this.role = AuthRole.student});

  AppUser copyWith({String? name, AuthRole? role}) =>
      AppUser(id: id, name: name ?? this.name, email: email, role: role ?? this.role);

  @override
  bool operator ==(Object other) =>
      other is AppUser && other.id == id && other.name == name && other.email == email && other.role == role;

  @override
  int get hashCode => Object.hash(id, name, email, role);
}
```

- [ ] **Step 2: `flutter analyze lib/data/models/app_user.dart`** — sem erros.
- [ ] **Step 3: Commit** — `git add lib/data/models/app_user.dart && git commit -m "feat(data): modelo AppUser com papel (student/admin)"`

---

### Task 3: Interface `AuthRepository` + `FakeAuthRepository` (TDD)

**Files:**
- Create: `lib/data/auth/auth_repository.dart`
- Create: `lib/data/auth/fake_auth_repository.dart`
- Test: `test/data/fake_auth_repository_test.dart`

- [ ] **Step 1: Definir a interface + exceção**

`lib/data/auth/auth_repository.dart`:
```dart
import '../models/app_user.dart';

/// Erro de autenticação com mensagem amigável (pt-BR) para a UI.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}

abstract interface class AuthRepository {
  /// Emite o usuário atual (ou null quando deslogado). Emite o estado inicial ao ser ouvido.
  Stream<AppUser?> authState();

  AppUser? get currentUser;

  Future<AppUser> signIn({required String email, required String password});

  Future<AppUser> register({required String name, required String email, required String password});

  Future<void> signOut();
}
```

- [ ] **Step 2: Escrever o teste do fake (FALHA primeiro)**

`test/data/fake_auth_repository_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/auth/auth_repository.dart';
import 'package:universe_app/data/auth/fake_auth_repository.dart';

void main() {
  test('registro cria usuário, autentica e emite no stream', () async {
    final repo = FakeAuthRepository();
    final emissions = <String?>[];
    final sub = repo.authState().listen((u) => emissions.add(u?.email));

    final user = await repo.register(name: 'Ana Beatriz', email: 'ana@aluno.ifsp.edu.br', password: 'Senha@123');
    expect(user.name, 'Ana Beatriz');
    expect(repo.currentUser?.email, 'ana@aluno.ifsp.edu.br');

    await repo.signOut();
    expect(repo.currentUser, isNull);

    final again = await repo.signIn(email: 'ana@aluno.ifsp.edu.br', password: 'Senha@123');
    expect(again.email, 'ana@aluno.ifsp.edu.br');

    await Future<void>.delayed(Duration.zero);
    expect(emissions, [null, 'ana@aluno.ifsp.edu.br', null, 'ana@aluno.ifsp.edu.br']);
    await sub.cancel();
  });

  test('signIn com senha errada lança AuthException', () async {
    final repo = FakeAuthRepository();
    await repo.register(name: 'X', email: 'x@aluno.ifsp.edu.br', password: 'Senha@123');
    await repo.signOut();
    expect(
      () => repo.signIn(email: 'x@aluno.ifsp.edu.br', password: 'errada'),
      throwsA(isA<AuthException>()),
    );
  });

  test('signIn de e-mail inexistente lança AuthException', () async {
    final repo = FakeAuthRepository();
    expect(
      () => repo.signIn(email: 'naoexiste@aluno.ifsp.edu.br', password: 'x'),
      throwsA(isA<AuthException>()),
    );
  });
}
```

- [ ] **Step 3: Rodar `flutter test test/data/fake_auth_repository_test.dart`** — CONFIRMAR FALHA (fake não existe).

- [ ] **Step 4: Implementar o fake**

`lib/data/auth/fake_auth_repository.dart`:
```dart
import 'dart:async';
import '../models/app_user.dart';
import 'auth_repository.dart';

/// Implementação em memória para desenvolvimento e testes (sem rede).
class FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<AppUser?>.broadcast();
  final Map<String, ({AppUser user, String password})> _accounts = {};
  AppUser? _current;
  var _seeded = false;

  @override
  Stream<AppUser?> authState() {
    // emite o estado atual para novos ouvintes
    Future.microtask(() => _controller.add(_current));
    return _controller.stream;
  }

  @override
  AppUser? get currentUser => _current;

  @override
  Future<AppUser> register({required String name, required String email, required String password}) async {
    final key = email.toLowerCase();
    if (_accounts.containsKey(key)) {
      throw const AuthException('Já existe uma conta com este e-mail.');
    }
    final user = AppUser(id: 'u${_accounts.length + 1}', name: name, email: email);
    _accounts[key] = (user: user, password: password);
    _current = user;
    _controller.add(_current);
    return user;
  }

  @override
  Future<AppUser> signIn({required String email, required String password}) async {
    final acc = _accounts[email.toLowerCase()];
    if (acc == null) throw const AuthException('Conta não encontrada.');
    if (acc.password != password) throw const AuthException('E-mail ou senha incorretos.');
    _current = acc.user;
    _controller.add(_current);
    return acc.user;
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(null);
  }

  /// Conta de demonstração pré-cadastrada (uso opcional em dev).
  void seedDemoUser() {
    if (_seeded) return;
    _seeded = true;
    _accounts['ana.silva@aluno.ifsp.edu.br'] =
        (user: const AppUser(id: 'demo', name: 'Ana Beatriz', email: 'ana.silva@aluno.ifsp.edu.br'), password: 'Universe@2026');
  }
}
```

- [ ] **Step 5: Rodar o teste** — esperado PASS.
- [ ] **Step 6: Commit** — `git add lib/data/auth/auth_repository.dart lib/data/auth/fake_auth_repository.dart test/data/fake_auth_repository_test.dart && git commit -m "feat(auth): AuthRepository + FakeAuthRepository (TDD)"`

---

### Task 4: `FirebaseAuthRepository` (implementação real)

**Files:**
- Create: `lib/data/auth/firebase_auth_repository.dart`

- [ ] **Step 1: Implementar via firebase_auth**

`lib/data/auth/firebase_auth_repository.dart`:
```dart
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);
  final FirebaseAuth _auth;

  AppUser? _map(User? u) => u == null
      ? null
      : AppUser(id: u.uid, name: u.displayName ?? (u.email?.split('@').first ?? 'Estudante'), email: u.email ?? '');

  @override
  Stream<AppUser?> authState() => _auth.authStateChanges().map(_map);

  @override
  AppUser? get currentUser => _map(_auth.currentUser);

  @override
  Future<AppUser> signIn({required String email, required String password}) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      return _map(cred.user)!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_msg(e.code));
    }
  }

  @override
  Future<AppUser> register({required String name, required String email, required String password}) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      await cred.user!.updateDisplayName(name.trim());
      await cred.user!.reload();
      return _map(_auth.currentUser)!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_msg(e.code));
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  String _msg(String code) => switch (code) {
        'invalid-email' => 'E-mail inválido.',
        'user-not-found' => 'Conta não encontrada.',
        'wrong-password' || 'invalid-credential' => 'E-mail ou senha incorretos.',
        'email-already-in-use' => 'Já existe uma conta com este e-mail.',
        'weak-password' => 'Senha muito fraca.',
        'network-request-failed' => 'Sem conexão. Tente novamente.',
        _ => 'Não foi possível concluir. Tente novamente.',
      };
}
```

- [ ] **Step 2: `flutter analyze lib/data/auth/`** — sem erros.
- [ ] **Step 3: Commit** — `git add lib/data/auth/firebase_auth_repository.dart && git commit -m "feat(auth): FirebaseAuthRepository (firebase_auth)"`

---

### Task 5: Providers de autenticação

**Files:**
- Create: `lib/core/providers/auth_provider.dart`

- [ ] **Step 1: Criar os providers**

`lib/core/providers/auth_provider.dart`:
```dart
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
```

- [ ] **Step 2: `flutter analyze lib/core/providers/auth_provider.dart`** — sem erros.
- [ ] **Step 3: Commit** — `git add lib/core/providers/auth_provider.dart && git commit -m "feat(auth): authRepositoryProvider e authStateProvider"`

---

### Task 6: Tela de Onboarding

**Files:**
- Create: `lib/features/auth/screens/onboarding_screen.dart`

Porta `OnboardingScreen` de `screens-auth.jsx`: gradiente verde, 3 slides (ícone, título, corpo), indicadores (dots), botão "Próximo"/"Começar", "Pular". Ao final → `/login`.

- [ ] **Step 1: Criar a tela**

`lib/features/auth/screens/onboarding_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/icon_tile.dart';
import '../../../shared/chrome/page_shell.dart';

class _Slide {
  final String icon, title, body;
  const _Slide(this.icon, this.title, this.body);
}

const _slides = [
  _Slide('institution', 'Tudo do seu campus,\nem um só lugar',
      'Encontre informações sobre o IFSP Pirituba, cursos, estrutura e contatos — sem complicação.'),
  _Slide('benefits', 'Benefícios que\nfazem a diferença',
      'Descubra auxílios governamentais e institucionais: Cadastro Único, PAP, monitoria, transporte e muito mais.'),
  _Slide('briefcase', 'Estágios, concursos\ne sua jornada',
      'Acompanhe vagas, editais e tire suas dúvidas direto com o campus. Sua vida acadêmica organizada.'),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final last = _i == _slides.length - 1;
    final s = _slides[_i];
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [c.heroFrom, c.heroTo]),
        ),
        child: SafeArea(
          child: Column(children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 22, 0),
                child: last ? const SizedBox(height: 20) : TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text('Pular', style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontWeight: FontWeight.w700)),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(34)),
                    child: Icon(appIcon(s.icon), size: 58, color: Colors.white),
                  ),
                  const SizedBox(height: 36),
                  Text(s.title, textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2, letterSpacing: -0.4)),
                  const SizedBox(height: 16),
                  Text(s.body, textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.5, height: 1.55, color: Colors.white.withValues(alpha: 0.78))),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 44),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (var k = 0; k < _slides.length; k++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8, width: k == _i ? 26 : 8,
                      decoration: BoxDecoration(
                        color: k == _i ? c.green400 : Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                ]),
                const SizedBox(height: 28),
                _WhiteButton(
                  label: last ? 'Começar' : 'Próximo',
                  onTap: () => last ? context.go('/login') : setState(() => _i++),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Botão branco sobre o gradiente (variação local do onboarding).
class _WhiteButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _WhiteButton({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      width: double.infinity, height: 56,
      child: Material(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16), onTap: onTap,
          child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(label, style: TextStyle(color: c.green800, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: c.green800, size: 20),
          ])),
        ),
      ),
    );
  }
}
```

> `kStatusH`/`PageShell`/`AppButton` import: usados para consistência; se algum import ficar sem uso, remova-o para o analyze passar.

- [ ] **Step 2: `flutter analyze lib/features/auth/screens/onboarding_screen.dart`** — sem erros (remova imports não usados).
- [ ] **Step 3: Commit** — `git add lib/features/auth/screens/onboarding_screen.dart && git commit -m "feat(auth): tela de onboarding"`

---

### Task 7: Tela de Login (Firebase real)

**Files:**
- Create: `lib/features/auth/screens/login_screen.dart`
- Test: `test/features/login_screen_test.dart`

Porta `LoginScreen`: topo verde com marca, sheet branca com campos E-mail/Senha, "Lembre-me", "Esqueci minha senha" (mostra aviso "em breve"), botão ENTRAR que chama `authRepository.signIn`, link "Cadastre-se" → `/register`. Erros do `AuthException` mostrados via SnackBar e/ou erro de campo.

- [ ] **Step 1: Criar a tela**

`lib/features/auth/screens/login_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/auth/auth_repository.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_field.dart';
import '../../../shared/chrome/page_shell.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String _email = '';
  String _pw = '';
  String? _emailErr, _pwErr;
  bool _loading = false;

  Future<void> _submit() async {
    setState(() {
      _emailErr = RegExp(r'^\S+@\S+\.\S+$').hasMatch(_email) ? null : 'Informe um e-mail válido';
      _pwErr = _pw.length < 6 ? 'Senha muito curta' : null;
    });
    if (_emailErr != null || _pwErr != null) return;
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).signIn(email: _email, password: _pw);
      // a navegação é feita pelo redirect do router ao detectar login.
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      body: Container(
        color: c.heroFrom,
        child: Column(children: [
          // topo com marca
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(0, kStatusH + 26, 0, 26),
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c.heroFrom, c.heroTo]),
            ),
            child: Column(children: [
              const Text('UNIVERSE', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 8),
              Text('Guia do estudante · IFSP Pirituba', style: TextStyle(color: Colors.white.withValues(alpha: 0.72), fontSize: 13)),
            ]),
          ),
          // sheet branca
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: c.bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Entrar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c.ink)),
                  const SizedBox(height: 4),
                  Text('Acesse com sua conta institucional', style: TextStyle(fontSize: 13.5, color: c.ink3)),
                  const SizedBox(height: 22),
                  AppField(label: 'E-mail', icon: 'mail', value: _email, error: _emailErr,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (v) => setState(() { _email = v; _emailErr = null; })),
                  const SizedBox(height: 14),
                  PasswordField(label: 'Senha', value: _pw, error: _pwErr,
                      onChanged: (v) => setState(() { _pw = v; _pwErr = null; })),
                  const SizedBox(height: 20),
                  AppButton(_loading ? 'Entrando…' : 'ENTRAR', full: true, onTap: _loading ? null : _submit),
                  const SizedBox(height: 18),
                  Center(
                    child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                      Text('Não tem uma conta? ', style: TextStyle(fontSize: 13.5, color: c.ink2)),
                      GestureDetector(
                        onTap: () => context.go('/register'),
                        child: Text('Cadastre-se', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: c.green700)),
                      ),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
```

- [ ] **Step 2: Teste de widget com FakeAuthRepository**

`test/features/login_screen_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:universe_app/core/providers/auth_provider.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/data/auth/auth_repository.dart';
import 'package:universe_app/data/auth/fake_auth_repository.dart';
import 'package:universe_app/features/auth/screens/login_screen.dart';

void main() {
  testWidgets('login com credenciais válidas autentica via repositório', (t) async {
    final fake = FakeAuthRepository()..seedDemoUser();
    final router = GoRouter(routes: [GoRoute(path: '/', builder: (c, s) => const LoginScreen())]);
    await t.pumpWidget(ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(fake)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ));
    await t.pumpAndSettle();

    await t.enterText(find.byType(TextField).at(0), 'ana.silva@aluno.ifsp.edu.br');
    await t.enterText(find.byType(TextField).at(1), 'Universe@2026');
    await t.tap(find.text('ENTRAR'));
    await t.pumpAndSettle();

    expect(fake.currentUser, isNotNull);
    expect(fake.currentUser!.email, 'ana.silva@aluno.ifsp.edu.br');
  });

  testWidgets('e-mail inválido mostra erro de campo', (t) async {
    final fake = FakeAuthRepository();
    final router = GoRouter(routes: [GoRoute(path: '/', builder: (c, s) => const LoginScreen())]);
    await t.pumpWidget(ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(fake)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).at(0), 'invalido');
    await t.enterText(find.byType(TextField).at(1), '123456');
    await t.tap(find.text('ENTRAR'));
    await t.pump();
    expect(find.text('Informe um e-mail válido'), findsOneWidget);
    expect(fake.currentUser, isNull);
  });
}
```

- [ ] **Step 3: Rodar `flutter test test/features/login_screen_test.dart`** — PASS. `flutter analyze` na tela sem erros.
- [ ] **Step 4: Commit** — `git add lib/features/auth/screens/login_screen.dart test/features/login_screen_test.dart && git commit -m "feat(auth): tela de login com Firebase Auth (TDD widget)"`

---

### Task 8: Tela de Registro (Firebase real)

**Files:**
- Create: `lib/features/auth/screens/register_screen.dart`

Porta `RegisterScreen`: campos Nome, E-mail, Senha (com 4 regras visuais + mínimo 8), Repetir senha. Botão CRIAR CONTA habilita só quando válido; chama `authRepository.register`. Erros via SnackBar. Voltar → `/login`.

- [ ] **Step 1: Criar a tela**

`lib/features/auth/screens/register_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/auth/auth_repository.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_field.dart';
import '../../../shared/chrome/page_shell.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  String _name = '', _email = '', _pw = '', _pw2 = '';
  bool _loading = false;

  bool get _emailOk => RegExp(r'^\S+@\S+\.\S+$').hasMatch(_email);
  List<(String, bool)> get _rules => [
        ('1 letra maiúscula', RegExp(r'[A-Z]').hasMatch(_pw)),
        ('1 letra minúscula', RegExp(r'[a-z]').hasMatch(_pw)),
        ('1 número', RegExp(r'[0-9]').hasMatch(_pw)),
        ('1 caractere especial', RegExp(r'[^A-Za-z0-9]').hasMatch(_pw)),
      ];
  bool get _pwOk => _rules.every((r) => r.$2) && _pw.length >= 8;
  bool get _matchOk => _pw2.isNotEmpty && _pw == _pw2;
  bool get _canSubmit => _name.trim().length > 2 && _emailOk && _pwOk && _matchOk;

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).register(name: _name, email: _email, password: _pw);
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.green050,
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IconButton(onPressed: () => context.go('/login'), icon: Icon(Icons.chevron_left, color: c.ink, size: 26)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Column(children: [
                  Text('Criar conta', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c.ink)),
                  const SizedBox(height: 4),
                  Text('Leva menos de um minuto', style: TextStyle(fontSize: 13, color: c.ink3)),
                ])),
                const SizedBox(height: 22),
                AppField(label: 'Nome completo', icon: 'user', value: _name, valid: _name.trim().length > 2,
                    onChanged: (v) => setState(() => _name = v)),
                const SizedBox(height: 13),
                AppField(label: 'E-mail institucional', icon: 'mail', value: _email, valid: _emailOk,
                    keyboardType: TextInputType.emailAddress,
                    error: _email.length > 4 && !_emailOk ? 'E-mail inválido' : null,
                    onChanged: (v) => setState(() => _email = v)),
                const SizedBox(height: 13),
                PasswordField(label: 'Senha', value: _pw, valid: _pwOk, onChanged: (v) => setState(() => _pw = v)),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2, childAspectRatio: 7, mainAxisSpacing: 6, crossAxisSpacing: 10,
                  children: [
                    for (final r in _rules)
                      Row(children: [
                        Icon(r.$2 ? Icons.check_circle : Icons.add_circle_outline, size: 14, color: r.$2 ? c.green500 : c.ink3),
                        const SizedBox(width: 6),
                        Text(r.$1, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: r.$2 ? c.green600 : c.ink3)),
                      ]),
                  ],
                ),
                const SizedBox(height: 13),
                PasswordField(label: 'Repetir senha', value: _pw2, valid: _matchOk,
                    error: _pw2.isNotEmpty && !_matchOk ? 'As senhas não coincidem' : null,
                    onChanged: (v) => setState(() => _pw2 = v)),
                const SizedBox(height: 24),
                AppButton(_loading ? 'Criando…' : 'CRIAR CONTA', full: true, onTap: (_canSubmit && !_loading) ? _submit : null),
                const SizedBox(height: 14),
                Text('Ao criar a conta você concorda com os Termos de Uso e a Política de Privacidade do IFSP.',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: c.ink3, height: 1.5)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
```

> `kStatusH`/`PageShell` imports podem não ser usados — remova imports sem uso para o analyze passar.

- [ ] **Step 2: `flutter analyze lib/features/auth/screens/register_screen.dart`** — sem erros.
- [ ] **Step 3: Commit** — `git add lib/features/auth/screens/register_screen.dart && git commit -m "feat(auth): tela de registro com Firebase Auth"`

---

### Task 9: Tela de Splash

**Files:**
- Create: `lib/features/auth/screens/splash_screen.dart`

Splash de marca (gradiente verde + UNIVERSE + spinner). O redirect do router decide o destino; a splash só é exibida enquanto `authState` está carregando.

- [ ] **Step 1: Criar a tela**

`lib/features/auth/screens/splash_screen.dart`:
```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [c.heroFrom, c.heroTo]),
        ),
        child: const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('UNIVERSE', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 3)),
            SizedBox(height: 28),
            SizedBox(width: 26, height: 26, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.6)),
          ]),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: `flutter analyze lib/features/auth/screens/splash_screen.dart`** — sem erros.
- [ ] **Step 3: Commit** — `git add lib/features/auth/screens/splash_screen.dart && git commit -m "feat(auth): tela de splash"`

---

### Task 10: Router com redirect por autenticação

**Files:**
- Modify: `lib/core/router/app_router.dart`
- Test: `test/router/auth_redirect_test.dart`

Substitui o `appRouter` global por um `routerProvider` que observa `authStateProvider` e redireciona: enquanto carrega → `/splash`; deslogado → `/onboarding` (permitindo `/login`,`/register`); logado tentando acessar tela de auth → `/home`.

- [ ] **Step 1: Reescrever o router**

`lib/core/router/app_router.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../../data/models/app_user.dart';
import '../../shared/chrome/bottom_nav.dart';
import '../../shared/chrome/menu_drawer.dart';
import '../../features/_placeholder/placeholder_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';

const _authRoutes = {'/onboarding', '/login', '/register'};

final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = ValueNotifier<AsyncValue<AppUser?>>(const AsyncValue.loading());
  ref.onDispose(authListenable.dispose);
  ref.listen(authStateProvider, (_, next) => authListenable.value = next, fireImmediately: true);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authListenable,
    redirect: (context, state) {
      final auth = authListenable.value;
      if (auth.isLoading) return '/splash';
      final loggedIn = auth.valueOrNull != null;
      final loc = state.matchedLocation;
      if (!loggedIn) return _authRoutes.contains(loc) ? null : '/onboarding';
      if (loc == '/splash' || _authRoutes.contains(loc)) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
      ShellRoute(
        builder: (context, state, child) => _Shell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (c, s) => const _Tab('Início', 'home')),
          GoRoute(path: '/cursos', builder: (c, s) => const _Tab('Cursos', 'cursos')),
          GoRoute(path: '/duvidas', builder: (c, s) => const _Tab('Dúvidas', 'duvidas')),
          GoRoute(path: '/perfil', builder: (c, s) => const _Tab('Perfil', 'perfil')),
        ],
      ),
    ],
  );
});

class _Tab extends ConsumerWidget {
  final String title, tab;
  const _Tab(this.title, this.tab);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlaceholderScreen(
      title: title, tab: tab,
      onMenu: () => Scaffold.of(context).openDrawer(),
      onBell: () {},
      onTab: (k) => context.go('/$k'),
    );
  }
}

class _Shell extends ConsumerWidget {
  final Widget child;
  const _Shell({required this.child});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    return Scaffold(
      backgroundColor: context.c.bg,
      drawer: MenuDrawer(
        userName: user?.name ?? 'Estudante',
        userEmail: user?.email ?? '',
        onNavigate: (route) { Navigator.pop(context); if (navTabs.any((t) => '/${t.key}' == route)) context.go(route); },
        onLogout: () { Navigator.pop(context); ref.read(authRepositoryProvider).signOut(); },
      ),
      body: child,
    );
  }
}
```

- [ ] **Step 2: Teste de redirect com fake**

`test/router/auth_redirect_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:universe_app/core/providers/auth_provider.dart';
import 'package:universe_app/core/router/app_router.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/data/auth/fake_auth_repository.dart';

void main() {
  testWidgets('deslogado cai no onboarding; após login vai para home', (t) async {
    final fake = FakeAuthRepository();
    final container = ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(fake)]);
    addTearDown(container.dispose);
    final router = container.read(routerProvider);

    await t.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ));
    await t.pumpAndSettle();
    expect(find.text('Próximo'), findsOneWidget); // onboarding visível

    await fake.register(name: 'Ana', email: 'ana@aluno.ifsp.edu.br', password: 'Senha@123');
    await t.pumpAndSettle();
    expect(find.text('Início'), findsWidgets); // home (placeholder + nav)
  });
}
```

- [ ] **Step 3: Rodar `flutter test test/router/auth_redirect_test.dart`** — PASS. (Se o redirect piscar a splash, `pumpAndSettle` resolve.)
- [ ] **Step 4: Commit** — `git add lib/core/router/app_router.dart test/router/auth_redirect_test.dart && git commit -m "feat(nav): redirect do router por estado de autenticacao"`

---

### Task 11: Inicializar Firebase + ligar routerProvider no main

**Files:**
- Modify: `lib/main.dart`
- Modify: `test/widget_test.dart` (o app agora exige Firebase/auth; usar fake)

- [ ] **Step 1: Reescrever main.dart**

`lib/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: UniverseApp()));
}

class UniverseApp extends ConsumerWidget {
  const UniverseApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Universe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      routerConfig: router,
    );
  }
}

/// Widget de teste do app que injeta um AuthRepository (evita Firebase em testes).
/// Usado por test/widget_test.dart.
```

- [ ] **Step 2: Atualizar o smoke test do app para usar fake**

`test/widget_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universe_app/core/providers/auth_provider.dart';
import 'package:universe_app/core/providers/theme_provider.dart';
import 'package:universe_app/core/router/app_router.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/data/auth/fake_auth_repository.dart';

void main() {
  testWidgets('deslogado, o app abre no onboarding', (t) async {
    SharedPreferences.setMockInitialValues({});
    final fake = FakeAuthRepository();
    await t.pumpWidget(ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(fake)],
      child: Consumer(builder: (c, ref, _) {
        ref.watch(themeModeProvider);
        return MaterialApp.router(theme: AppTheme.light, routerConfig: ref.watch(routerProvider));
      }),
    ));
    await t.pumpAndSettle();
    expect(find.text('Começar'), findsNothing); // primeiro slide é "Próximo"
    expect(find.text('Próximo'), findsOneWidget);
  });
}
```

- [ ] **Step 3: Rodar a suíte completa**

Run: `flutter test`
Expected: TODOS os testes PASS (app_field, fake_auth_repository, login_screen, auth_redirect, widget_test, e os do Plano 1).

- [ ] **Step 4: `flutter analyze`** — esperado "No issues found!".
- [ ] **Step 5: Commit** — `git add lib/main.dart test/widget_test.dart && git commit -m "feat: inicializa Firebase e liga router por auth no app"`

---

### Task 12: Verificação manual + diário

**Files:** atualização do diário.

- [ ] **Step 1: Rodar** `flutter run -d chrome --web-port 5000 --web-hostname localhost`
- [ ] **Step 2: Verificar fluxo:** app abre no onboarding (deslogado) → "Começar" leva ao login → "Cadastre-se" abre registro → criar conta (com Firebase real) → cai na Home com as 4 abas → abrir drawer → "Sair" volta ao onboarding/login.
  - Observação: requer o projeto Firebase com **Email/Password** habilitado no console. Se não estiver, o cadastro retorna erro amigável; nesse caso, habilitar o provedor no Firebase Authentication.
- [ ] **Step 3: Registrar entrada no diário** `docs/desenvolvimento/diario-de-desenvolvimento.md` resumindo o Plano 2: arquitetura de auth (interface + fake + firebase), telas, redirect, e estado entregue.
- [ ] **Step 4: Commit** — `git add docs/desenvolvimento/diario-de-desenvolvimento.md && git commit -m "docs: registra conclusao do Plano 2 (autenticacao)"`

---

## Self-Review (cobertura)

- **Spec §7 (Auth real, splash decide rota):** Tasks 4,5,9,10,11 ✓ (Firebase Auth, splash + redirect).
- **Spec §4 (papéis student/admin):** `AppUser.role` + `AuthRole` (Task 2) ✓ — admin será usado no painel (plano futuro).
- **Arquitetura híbrida (interface de repositório):** `AuthRepository` + Fake + Firebase (Tasks 3,4) ✓ — UI não depende do Firebase direto.
- **Telas de auth fiéis ao design:** onboarding/login/registro/splash (Tasks 6–9) ✓.
- **Design system completado:** AppField/PasswordField (Task 1) ✓.
- **Testabilidade sem rede:** Fake + overrides Riverpod nos testes (Tasks 3,7,10,11) ✓.

**Sem placeholders.** Tipos consistentes: `AuthRepository`/`AppUser`/`AuthException`, `authRepositoryProvider`/`authStateProvider`, `routerProvider`. Imports não usados em telas devem ser removidos pelo implementador para o `analyze` ficar limpo (apontado nas tasks 6 e 8).

## Riscos / notas
1. **Firebase Email/Password** precisa estar habilitado no console do projeto para o cadastro/login reais funcionarem (verificação na Task 12).
2. **Persistência de sessão:** `firebase_auth` já persiste a sessão localmente; o redirect do router cobre o reinício do app.
3. **"Esqueci minha senha"/"Lembre-me":** fora de escopo nesta rodada (a UI pode exibir aviso "em breve"); implementar depois se desejado.
