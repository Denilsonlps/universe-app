import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/courses.dart';
import '../../../data/models/app_notification.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/list_row.dart';

String _fmt(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 60) return 'há ${diff.inMinutes <= 0 ? 1 : diff.inMinutes} min';
  if (diff.inHours < 24) return 'há ${diff.inHours} h';
  if (diff.inDays < 7) return 'há ${diff.inDays} d';
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}

class NotificacoesScreen extends ConsumerStatefulWidget {
  const NotificacoesScreen({super.key});
  @override
  ConsumerState<NotificacoesScreen> createState() => _NotificacoesScreenState();
}

class _NotificacoesScreenState extends ConsumerState<NotificacoesScreen> {
  bool _marked = false;

  /// Marca a central como vista (zera o badge) — uma vez, quando o perfil carrega.
  void _markSeen() {
    if (_marked) return;
    final profile = ref.read(currentProfileProvider).valueOrNull;
    if (profile == null) return;
    _marked = true;
    ref.read(profileRepositoryProvider)
        .save(profile.copyWith(lastSeenNotificationsAt: DateTime.now()))
        .then((_) => ref.invalidate(currentProfileProvider));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final async = ref.watch(notificationsProvider);
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    WidgetsBinding.instance.addPostFrameCallback((_) => _markSeen());

    final meuCursoCurto = profile?.course == null ? null : courseShort(profile!.course!);
    final onlyMine = profile?.onlyMyCourse ?? false;

    return PageShell(
      bodyPadding: const EdgeInsets.all(16),
      header: GreenHero(
        title: 'Notificações',
        subtitle: onlyMine ? 'Filtrando pelo seu curso' : 'Novidades para você',
        icon: 'bell', onBack: () => context.pop(),
      ),
      body: AsyncListView<AppNotification>(
        value: async,
        onRetry: () => ref.invalidate(notificationsProvider),
        emptyTitle: 'Sem notificações',
        emptyBody: 'Quando surgir uma vaga ou notícia, você verá por aqui.',
        data: (all) {
          final list = onlyMine ? all.where((n) => n.matchesCourse(meuCursoCurto)).toList() : all;
          if (list.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(child: Text('Nenhuma notificação para o seu curso.', style: TextStyle(fontSize: 13, color: c.ink3))),
            );
          }
          return Column(children: [
            for (final n in list) Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ListRow(
                icon: n.icon,
                title: n.title,
                subtitle: '${n.body}\n${_fmt(n.createdAt)}',
                showChevron: n.route != null,
                onTap: n.route == null ? null : () => context.push(n.route!),
              ),
            ),
          ]);
        },
      ),
    );
  }
}
