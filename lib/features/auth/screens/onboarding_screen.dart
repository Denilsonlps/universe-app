import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/onboarding_provider.dart';
import '../../../shared/widgets/icon_tile.dart';

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

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _i = 0;

  void _finish() {
    ref.read(onboardingSeenProvider.notifier).markSeen();
    context.go('/login');
  }

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
                  onPressed: _finish,
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
                  onTap: () => last ? _finish() : setState(() => _i++),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

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
