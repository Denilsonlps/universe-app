import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/courses.dart';
import '../../../data/models/contest.dart';
import '../../../data/models/internship.dart';
import '../../../data/models/testimonial.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/icon_tile.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/stars.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/user_avatar.dart';

class EstagioScreen extends ConsumerStatefulWidget {
  final String initialCourse;
  const EstagioScreen({super.key, this.initialCourse = 'Todos'});
  @override
  ConsumerState<EstagioScreen> createState() => _EstagioScreenState();
}

class _EstagioScreenState extends ConsumerState<EstagioScreen> {
  late String _course = widget.initialCourse;
  bool _estagios = true;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final repo = ref.watch(universeRepositoryProvider);
    final vagas = repo.internships(courseFilter: _course);
    final concursos = repo.contests();
    final depo = repo.testimonials();

    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(
        title: 'Estágio e Concursos', subtitle: 'Vagas, editais e oportunidades', icon: 'briefcase',
        onBack: () => context.pop(),
        action: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Painel do Setor de Estágios (em breve)'))),
          child: Container(
            width: 38, height: 38, alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(11)),
            child: Icon(appIcon('shield'), size: 20, color: Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // toggle de abas
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: c.bg2, borderRadius: BorderRadius.circular(13)),
            child: Row(children: [
              for (final (label, isEst) in const [('Estágios', true), ('Concursos', false)])
                Expanded(child: GestureDetector(
                  onTap: () => setState(() => _estagios = isEst),
                  child: Container(
                    height: 38, alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _estagios == isEst ? c.card : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: _estagios == isEst ? c.green800 : c.ink3)),
                  ),
                )),
            ]),
          ),
          const SizedBox(height: 16),
          if (_estagios) ...[
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: courseShortLabels.length,
                separatorBuilder: (context, i) => const SizedBox(width: 9),
                itemBuilder: (context, i) => AppChip(courseShortLabels[i], active: _course == courseShortLabels[i], onTap: () => setState(() => _course = courseShortLabels[i])),
              ),
            ),
            const SizedBox(height: 16),
            if (vagas.isEmpty)
              EmptyState(icon: 'briefcase', title: 'Nenhuma vaga para este curso', body: 'Tente outro curso.', action: 'Ver todos', onAction: () => setState(() => _course = 'Todos'))
            else
              for (final v in vagas) Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _VagaCard(v: v, onTap: () => context.push('/estagio/vaga', extra: v)),
              ),
            if (depo.isNotEmpty) ...[
              const SizedBox(height: 14),
              SectionTitle('Depoimentos', action: 'Ver todos', onAction: () => context.push('/estagio/depoimentos')),
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: depo.length,
                  separatorBuilder: (context, i) => const SizedBox(width: 12),
                  itemBuilder: (context, i) => SizedBox(width: 250, child: _DepoCard(t: depo[i])),
                ),
              ),
            ],
          ] else ...[
            if (concursos.isEmpty)
              const EmptyState(icon: 'doc', title: 'Nenhum concurso aberto', body: 'No momento não há concursos com inscrições abertas.')
            else
              for (final ct in concursos) Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ConcursoCard(ct: ct, onTap: () => context.push('/estagio/concurso', extra: ct)),
              ),
          ],
        ]),
      ),
    );
  }
}

class _VagaCard extends StatelessWidget {
  final Internship v;
  final VoidCallback onTap;
  const _VagaCard({required this.v, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    Widget chip(String t, {bool strong = false}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: strong ? c.green050 : c.bg2, borderRadius: BorderRadius.circular(999)),
      child: Text(t, style: TextStyle(fontSize: 11, fontWeight: strong ? FontWeight.w700 : FontWeight.w600, color: strong ? c.green700 : c.ink2)),
    );
    return AppCard(
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(v.role, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink, height: 1.3))),
          const SizedBox(width: 8),
          if (!v.open) const StatusBadge(closed: true)
          else if (v.tag != null) Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(color: c.green500, borderRadius: BorderRadius.circular(999)),
            child: Text(v.tag!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
          )
          else const StatusBadge(closed: false),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Icon(appIcon('institution'), size: 14, color: c.ink3),
          const SizedBox(width: 6),
          Flexible(child: Text(v.companyName, style: TextStyle(fontSize: 12.5, color: c.ink2), overflow: TextOverflow.ellipsis)),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [chip(v.mode), chip('${v.grant}/mês', strong: true), chip(v.course)]),
      ]),
    );
  }
}

class _ConcursoCard extends StatelessWidget {
  final Contest ct;
  final VoidCallback onTap;
  const _ConcursoCard({required this.ct, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final open = ct.isOpenAt(DateTime.now());
    return AppCard(
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(ct.role, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink, height: 1.3))),
          const SizedBox(width: 8),
          StatusBadge(closed: !open, openLabel: 'Abertas', closedLabel: 'Encerradas'),
        ]),
        const SizedBox(height: 6),
        Text(ct.org, style: TextStyle(fontSize: 12.5, color: c.ink2)),
        const SizedBox(height: 12),
        Wrap(spacing: 10, runSpacing: 6, children: [
          Text(ct.vagas, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.green700)),
          Text(ct.salary, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.ink2)),
        ]),
      ]),
    );
  }
}

class _DepoCard extends StatelessWidget {
  final Testimonial t;
  const _DepoCard({required this.t});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          UserAvatar(t.name, size: 40),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.name, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink), overflow: TextOverflow.ellipsis),
            Text('${t.course} · ${t.org}', style: TextStyle(fontSize: 11, color: c.ink3), overflow: TextOverflow.ellipsis),
          ])),
        ]),
        const SizedBox(height: 9),
        Stars(t.stars),
        const SizedBox(height: 9),
        Expanded(child: Text('"${t.text}"', maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, height: 1.5, color: c.ink2))),
      ]),
    );
  }
}
