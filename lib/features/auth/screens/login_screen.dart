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
