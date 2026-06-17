import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/contest.dart';
import '../../../data/models/internship.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/icon_tile.dart';
import '../../../shared/widgets/status_badge.dart';

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});
  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen> {
  bool _vagas = true;

  Future<void> _confirmDelete(String titulo, Future<void> Function() onDelete) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Excluir'),
        content: Text('Excluir "$titulo"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (ok == true) {
      await onDelete();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Excluído')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final repo = ref.read(universeRepositoryProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: c.green800, foregroundColor: Colors.white,
        onPressed: () => context.push(_vagas ? '/admin/vaga' : '/admin/concurso'),
        icon: const Icon(Icons.add),
        label: Text(_vagas ? 'Nova vaga' : 'Novo concurso'),
      ),
      body: PageShell(
        bodyPadding: const EdgeInsets.all(16),
        header: PageHeader(title: 'Painel — Setor de Estágios', onBack: () => context.pop()),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: c.bg2, borderRadius: BorderRadius.circular(13)),
            child: Row(children: [
              for (final (label, isV) in const [('Vagas', true), ('Concursos', false)])
                Expanded(child: GestureDetector(
                  onTap: () => setState(() => _vagas = isV),
                  child: Container(
                    height: 38, alignment: Alignment.center,
                    decoration: BoxDecoration(color: _vagas == isV ? c.card : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                    child: Text(label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: _vagas == isV ? c.green800 : c.ink3)),
                  ),
                )),
            ]),
          ),
          const SizedBox(height: 16),
          if (_vagas)
            AsyncListView<Internship>(
              value: ref.watch(allInternshipsProvider),
              onRetry: () => ref.invalidate(allInternshipsProvider),
              emptyTitle: 'Nenhuma vaga cadastrada', emptyBody: 'Toque em "Nova vaga" para começar.',
              data: (list) => Column(children: [
                for (final v in list) Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AdminRow(
                    icon: 'briefcase', title: v.role, subtitle: v.companyName,
                    badge: StatusBadge(closed: !v.open),
                    onEdit: () => context.push('/admin/vaga', extra: v),
                    onDelete: () => _confirmDelete(v.role, () => repo.deleteInternship(v.id)),
                  ),
                ),
              ]),
            )
          else
            AsyncListView<Contest>(
              value: ref.watch(allContestsProvider),
              onRetry: () => ref.invalidate(allContestsProvider),
              emptyTitle: 'Nenhum concurso cadastrado', emptyBody: 'Toque em "Novo concurso" para começar.',
              data: (list) => Column(children: [
                for (final ct in list) Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AdminRow(
                    icon: 'doc', title: ct.role, subtitle: ct.org,
                    badge: StatusBadge(closed: !ct.isOpenAt(DateTime.now()), openLabel: 'Abertas', closedLabel: 'Encerradas'),
                    onEdit: () => context.push('/admin/concurso', extra: ct),
                    onDelete: () => _confirmDelete(ct.role, () => repo.deleteContest(ct.id)),
                  ),
                ),
              ]),
            ),
        ]),
      ),
    );
  }
}

class _AdminRow extends StatelessWidget {
  final String icon, title, subtitle;
  final Widget badge;
  final VoidCallback onEdit, onDelete;
  const _AdminRow({required this.icon, required this.title, required this.subtitle, required this.badge, required this.onEdit, required this.onDelete});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AppCard(
      onTap: onEdit, padding: const EdgeInsets.all(12),
      child: Row(children: [
        IconTile(icon, size: 44),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.ink), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(subtitle, style: TextStyle(fontSize: 12, color: c.ink3), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          badge,
        ])),
        IconButton(onPressed: onDelete, icon: Icon(Icons.delete_outline, color: c.error, size: 22)),
      ]),
    );
  }
}
