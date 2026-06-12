import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/auth/auth_repository.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_field.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
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
