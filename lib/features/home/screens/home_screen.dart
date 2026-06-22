import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/news.dart';
import '../../news/widgets/news_card.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/bottom_nav.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/icon_tile.dart';
import '../../../shared/widgets/list_row.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/user_avatar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _tabRoutes = {'/home', '/cursos', '/duvidas', '/perfil'};
  static const _pushRoutes = {'/ifsp', '/beneficios/gov', '/beneficios/inst', '/estagio', '/cadastrar'};

  void _go(BuildContext context, String route) {
    if (_tabRoutes.contains(route)) {
      context.go(route);
    } else if (_pushRoutes.contains(route)) {
      context.push(route);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Em breve')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final user = ref.watch(authStateProvider).valueOrNull;
    final firstName = (user?.name ?? 'Estudante').split(' ').first;
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Bom dia' : hour < 18 ? 'Boa tarde' : 'Boa noite';

    final homeItems = <({String route, String icon, String title, String sub})>[
      (route: '/ifsp', icon: 'institution', title: 'IFSP Pirituba', sub: 'Conheça o campus, estrutura e contatos'),
      (route: '/cursos', icon: 'cap', title: 'Cursos', sub: 'Graduações, técnicos e pós-graduação'),
      (route: '/beneficios/gov', icon: 'benefits', title: 'Benefícios Governamentais', sub: 'Cadastro Único, ID Jovem, transporte e isenções'),
      (route: '/beneficios/inst', icon: 'award', title: 'Benefícios Institucionais', sub: 'PAP, monitoria, iniciação científica e extensão'),
      (route: '/estagio', icon: 'briefcase', title: 'Estágio e Concursos', sub: 'Vagas, editais e concursos públicos'),
      (route: '/cadastrar', icon: 'edit', title: 'Cadastrar informações', sub: 'Atualize seus dados e documentos'),
    ];
    final quick = <({String route, String icon, String label})>[
      (route: '/moradia', icon: 'house', label: 'Moradia'),
      (route: '/duvidas', icon: 'question', label: 'Dúvidas'),
      (route: '/beneficios/gov', icon: 'card', label: 'ID Jovem'),
      (route: '/ifsp', icon: 'pin', label: 'Endereço'),
    ];

    return PageShell(
      bodyPadding: const EdgeInsets.all(16),
      header: HomeHeader(
        onMenu: () => Scaffold.of(context).openDrawer(),
        onBell: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Em breve'))),
      ),
      bottomNav: AppBottomNav(current: 'home', onTap: (k) => context.go('/$k')),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // saudação
        Row(children: [
          UserAvatar(user?.name ?? 'Estudante', size: 46),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$greeting,', style: TextStyle(fontSize: 12.5, color: c.ink3, fontWeight: FontWeight.w600)),
            Text(firstName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.ink, letterSpacing: -0.3)),
          ])),
        ]),
        const SizedBox(height: 16),
        // busca (placeholder)
        AppCard(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Em breve'))),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          radius: 14,
          child: Row(children: [
            Icon(appIcon('search'), size: 19, color: c.ink3),
            const SizedBox(width: 10),
            Text('Buscar cursos, benefícios, dúvidas…', style: TextStyle(fontSize: 14, color: c.ink3)),
          ]),
        ),
        const SizedBox(height: 18),
        // ações rápidas
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: quick.length,
            separatorBuilder: (context2, i2) => const SizedBox(width: 9),
            itemBuilder: (_, i) => AppChip(quick[i].label, onTap: () => _go(context, quick[i].route)),
          ),
        ),
        const SizedBox(height: 20),
        // card de destaque
        _HighlightCard(onTap: () => _go(context, '/estagio')),
        const SizedBox(height: 22),
        // Notícias (carrossel) — só aparece se houver publicadas
        ...(() {
          final news = ref.watch(publishedNewsProvider).valueOrNull ?? const <News>[];
          if (news.isEmpty) return const <Widget>[];
          final top = news.take(6).toList();
          return [
            Row(children: [
              Expanded(child: SectionTitle('Notícias')),
              GestureDetector(
                onTap: () => context.push('/noticias'),
                child: Text('Ver todas', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.green700)),
              ),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              height: 148,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: top.length,
                separatorBuilder: (context2, i2) => const SizedBox(width: 12),
                itemBuilder: (_, i) => NewsCard(news: top[i], compact: true, onTap: () => context.push('/noticias/${top[i].id}', extra: top[i])),
              ),
            ),
            const SizedBox(height: 22),
          ];
        }()),
        const SectionTitle('Explorar'),
        for (final it in homeItems) Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: ListRow(icon: it.icon, title: it.title, subtitle: it.sub, onTap: () => _go(context, it.route)),
        ),
      ]),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final VoidCallback onTap;
  const _HighlightCard({required this.onTap});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c.green600, c.green900]),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(999)),
            child: const Text('EM DESTAQUE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: Colors.white)),
          ),
          const SizedBox(height: 12),
          const Text('Estágio em Dev Web', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
          const SizedBox(height: 4),
          Text('Prefeitura de SP · bolsa R\$ 1.100 + VT', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
          const SizedBox(height: 14),
          Row(children: [
            const Text('Ver vaga', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(width: 5),
            Icon(appIcon('chevR'), size: 16, color: Colors.white),
          ]),
        ]),
      ),
    );
  }
}
