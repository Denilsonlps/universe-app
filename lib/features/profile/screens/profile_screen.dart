import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/user_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _name = 'Ana Beatriz';
  static const _email = 'ana.silva@aluno.ifsp.edu.br';
  static const _course = 'Análise e Desenvolvimento de Sistemas';
  static const _enroll = 'PT3024187';

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return ColoredBox(
      color: AppColors.bg,
      child: Column(
        children: [
          // Green hero header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.green700, AppColors.green900],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x38003D28),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(20, topPad + 18, 20, 24),
            child: Column(
              children: [
                const UserAvatar(name: _name, size: 84),
                const SizedBox(height: 12),
                const Text(
                  _name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  _email,
                  style: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.78)),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _StatChip(label: 'Curso', value: _course.split(' ')[0]),
                    const SizedBox(width: 10),
                    _StatChip(label: 'Matrícula', value: _enroll),
                    const SizedBox(width: 10),
                    _StatChip(label: 'Semestre', value: '4º'),
                  ],
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _MenuGroup(
                  rows: [
                    _MenuRow(icon: Icons.edit_rounded, label: 'Editar perfil', onTap: () => context.go('/profile/edit')),
                    _MenuRow(icon: Icons.badge_rounded, label: 'Carteirinha digital', onTap: () => context.go('/profile/card')),
                    _MenuRow(icon: Icons.lock_rounded, label: 'Alterar senha', onTap: () {}),
                  ],
                ),
                const SizedBox(height: 14),
                _MenuGroup(
                  rows: [
                    _MenuRow(icon: Icons.help_rounded, label: 'Central de dúvidas', onTap: () => context.go('/faqs')),
                    _MenuRow(icon: Icons.account_balance_rounded, label: 'Sobre o IFSP Pirituba', onTap: () => context.go('/campus')),
                    _MenuRow(icon: Icons.description_rounded, label: 'Termos e privacidade', onTap: () {}),
                  ],
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => context.go('/onboarding'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF0D281C).withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1)),
                        BoxShadow(color: const Color(0xFF0D281C).withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, size: 20, color: AppColors.error),
                        SizedBox(width: 9),
                        Text('Sair da conta', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.error)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'UNIVERSE · v1.0 · IFSP Pirituba',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppColors.ink3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.72)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final List<_MenuRow> rows;
  const _MenuGroup({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0D281C).withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1)),
          BoxShadow(color: const Color(0xFF0D281C).withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: List.generate(rows.length, (i) {
          return Column(
            children: [
              rows[i],
              if (i < rows.length - 1)
                const Divider(height: 1, color: AppColors.line, indent: 16, endIndent: 16),
            ],
          );
        }),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _MenuRow({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: AppColors.card,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 21, color: AppColors.green700),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
            ),
            const Icon(Icons.chevron_right, size: 17, color: AppColors.ink3),
          ],
        ),
      ),
    );
  }
}
