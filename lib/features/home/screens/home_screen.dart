import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/list_row.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../../shared/widgets/universe_wordmark.dart';

// Home items — mirrors DATA.home from the JSX prototype
class _HomeItem {
  final String title;
  final String sub;
  final IconData icon;
  final String route;
  const _HomeItem({required this.title, required this.sub, required this.icon, required this.route});
}

const _homeItems = [
  _HomeItem(title: 'IFSP Pirituba', sub: 'Conheça o campus, estrutura e contatos', icon: Icons.account_balance_rounded, route: '/campus'),
  _HomeItem(title: 'Cursos', sub: 'Graduações, técnicos e pós-graduação', icon: Icons.school_rounded, route: '/courses'),
  _HomeItem(title: 'Benefícios Governamentais', sub: 'Cadastro Único, ID Jovem, transporte e isenções', icon: Icons.card_giftcard_rounded, route: '/benefits/gov'),
  _HomeItem(title: 'Benefícios Institucionais', sub: 'PAP, monitoria, iniciação científica e extensão', icon: Icons.emoji_events_rounded, route: '/benefits/inst'),
  _HomeItem(title: 'Estágio e Concursos', sub: 'Vagas, editais e concursos públicos', icon: Icons.work_rounded, route: '/internships'),
  _HomeItem(title: 'Cadastrar informações', sub: 'Atualize seus dados e documentos', icon: Icons.edit_rounded, route: '/profile/edit'),
];

class _QuickItem {
  final String label;
  final IconData icon;
  final String route;
  const _QuickItem({required this.label, required this.icon, required this.route});
}

const _quickItems = [
  _QuickItem(label: 'Moradia', icon: Icons.house_rounded, route: '/housing'),
  _QuickItem(label: 'Dúvidas', icon: Icons.help_rounded, route: '/faqs'),
  _QuickItem(label: 'ID Jovem', icon: Icons.credit_card_rounded, route: '/benefits/gov'),
  _QuickItem(label: 'Endereço', icon: Icons.location_on_rounded, route: '/campus'),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.bg,
      child: Column(
        children: [
          _HomeHeader(onNotificationTap: () => context.go('/notifications')),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Greeting(greeting: _greeting()),
                  const SizedBox(height: 16),
                  _SearchBar(onTap: () => context.go('/search')),
                  const SizedBox(height: 20),
                  _QuickChips(),
                  const SizedBox(height: 4),
                  _HighlightCard(onTap: () => context.go('/internships')),
                  const SizedBox(height: 22),
                  const SectionTitle(label: 'Explorar'),
                  _HomeList(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Home header: menu · wordmark · bell ─────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final VoidCallback onNotificationTap;
  const _HomeHeader({required this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      padding: EdgeInsets.fromLTRB(
        18,
        MediaQuery.of(context).padding.top + 14,
        18,
        14,
      ),
      child: Row(
        children: [
          _HeaderButton(
            icon: Icons.menu_rounded,
            onTap: () {},
          ),
          const Expanded(
            child: Center(child: UniverseWordmark(height: 24)),
          ),
          _HeaderButton(
            icon: Icons.notifications_outlined,
            onTap: onNotificationTap,
            badge: true,
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool badge;
  const _HeaderButton({required this.icon, this.onTap, this.badge = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 22, color: AppColors.ink),
            if (badge)
              Positioned(
                top: 9,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.card, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Greeting ─────────────────────────────────────────────────────────────────

class _Greeting extends StatelessWidget {
  final String greeting;
  const _Greeting({required this.greeting});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const UserAvatar(name: 'Ana Beatriz', size: 46),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$greeting,',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink3,
                ),
              ),
              const Text(
                'Ana',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppTheme.cardShadow,
        ),
        child: const Row(
          children: [
            Icon(Icons.search_rounded, size: 19, color: AppColors.ink3),
            SizedBox(width: 10),
            Text(
              'Buscar cursos, benefícios, dúvidas…',
              style: TextStyle(fontSize: 14, color: AppColors.ink3),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick action chips ────────────────────────────────────────────────────────

class _QuickChips extends StatelessWidget {
  const _QuickChips();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: _quickItems.length,
        separatorBuilder: (_, _) => const SizedBox(width: 9),
        itemBuilder: (context, i) {
          final q = _quickItems[i];
          return AppChip(
            label: q.label,
            icon: q.icon,
            onTap: () => context.go(q.route),
          );
        },
      ),
    );
  }
}

// ── Highlight card ────────────────────────────────────────────────────────────

class _HighlightCard extends StatelessWidget {
  final VoidCallback onTap;
  const _HighlightCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.green600, AppColors.green900],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40005730),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Positioned(
              right: -28,
              top: -28,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'EM DESTAQUE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Estágio em Dev Web',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Prefeitura de SP · bolsa R\$ 1.100 + VT',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 14),
                const Row(
                  children: [
                    Text(
                      'Ver vaga',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 16, color: Colors.white),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Home list ─────────────────────────────────────────────────────────────────

class _HomeList extends StatelessWidget {
  const _HomeList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(_homeItems.length, (i) {
        final item = _homeItems[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: ListRow(
            icon: item.icon,
            title: item.title,
            subtitle: item.sub,
            onTap: () => context.go(item.route),
          ),
        );
      }),
    );
  }
}
