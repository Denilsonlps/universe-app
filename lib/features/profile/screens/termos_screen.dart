import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/section_title.dart';

/// Termos de uso e política de privacidade do app (texto estático).
class TermosScreen extends StatelessWidget {
  const TermosScreen({super.key});

  static const _blocos = <(String, String)>[
    ('Sobre o app', 'O Universe é um aplicativo de apoio aos estudantes do IFSP Campus Pirituba, '
        'reunindo informações sobre cursos, benefícios, vagas de estágio, concursos e notícias.'),
    ('Dados que coletamos', 'Para criar sua conta usamos nome e e-mail. No seu perfil você pode informar, '
        'opcionalmente, curso e matrícula. Esses dados ficam armazenados com segurança no Firebase e são '
        'usados apenas para personalizar sua experiência no app.'),
    ('Uso das informações', 'As vagas, notícias e conteúdos são curados pela equipe e por rotinas automatizadas. '
        'Os links levam às fontes oficiais; recomendamos sempre conferir prazos e requisitos diretamente nelas.'),
    ('Seus direitos', 'Você pode editar ou remover seus dados de perfil a qualquer momento e encerrar sua conta. '
        'Não compartilhamos seus dados pessoais com terceiros para fins comerciais.'),
    ('Contato', 'Dúvidas sobre privacidade podem ser encaminhadas ao Setor de Estágios do campus.'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return PageShell(
      bodyPadding: const EdgeInsets.all(16),
      header: GreenHero(title: 'Termos e privacidade', subtitle: 'Como tratamos seus dados', icon: 'doc', onBack: () => context.pop()),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final (titulo, corpo) in _blocos) ...[
          SectionTitle(titulo),
          const SizedBox(height: 8),
          Text(corpo, style: TextStyle(fontSize: 13.5, height: 1.55, color: c.ink2)),
          const SizedBox(height: 18),
        ],
        Text('UNIVERSE · v1.0 · IFSP Pirituba', style: TextStyle(fontSize: 11, color: c.ink3)),
      ]),
    );
  }
}
