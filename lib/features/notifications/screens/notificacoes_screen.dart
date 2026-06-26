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
  DateTime? _seenSnapshot; // "visto" no momento de abrir (para destacar as novas)

  /// Marca a central como vista (zera o badge) — uma vez, quando o perfil carrega.
  void _markSeen() {
    if (_marked) return;
    final profile = ref.read(currentProfileProvider).valueOrNull;
    if (profile == null) return;
    _marked = true;
    setState(() => _seenSnapshot = profile.lastSeenNotificationsAt);
    ref.read(profileRepositoryProvider)
        .save(profile.copyWith(lastSeenNotificationsAt: DateTime.now()))
        .then((_) => ref.invalidate(currentProfileProvider));
  }

  bool _isNova(DateTime createdAt) =>
      _seenSnapshot == null ? true : createdAt.isAfter(_seenSnapshot!);

  /// Descarta (some só para este usuário) — guarda o id no perfil.
  void _descartar(String id) {
    final profile = ref.read(currentProfileProvider).valueOrNull;
    if (profile == null) return;
    final novos = [...profile.dismissedNotifications, id];
    ref.read(profileRepositoryProvider)
        .save(profile.copyWith(dismissedNotifications: novos))
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
    final dismissed = profile?.dismissedNotifications ?? const <String>[];

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
          final list = [
            for (final n in all)
              if (!dismissed.contains(n.id) && (!onlyMine || n.matchesCourse(meuCursoCurto))) n,
          ];
          if (list.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(child: Text('Nenhuma notificação por aqui.', style: TextStyle(fontSize: 13, color: c.ink3))),
            );
          }
          return Column(children: [
            for (final n in list) Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Dismissible(
                key: ValueKey(n.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _descartar(n.id),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 22),
                  decoration: BoxDecoration(color: c.error.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
                  child: Icon(Icons.delete_outline, color: c.error),
                ),
                child: ListRow(
                  icon: n.icon,
                  title: n.title,
                  subtitle: '${n.body}\n${_fmt(n.createdAt)}',
                  trailing: _isNova(n.createdAt)
                      ? Container(width: 9, height: 9, decoration: BoxDecoration(color: c.green500, shape: BoxShape.circle))
                      : null,
                  showChevron: n.route != null,
                  onTap: n.route == null ? null : () => context.push(n.route!),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}
