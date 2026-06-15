# Plano 4B — Telas: Benefícios e Estágio/Concursos (Universe)

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`).

**Goal:** Implementar as telas de Benefícios (governamentais e institucionais + detalhe) e de Estágio/Concursos (lista com abas e filtro por curso, detalhe de vaga e de concurso, depoimentos), consumindo o `UniverseRepository`.

**Architecture:** Telas em `features/benefits` e `features/internships`. Lêem `universeRepositoryProvider`. Reusam design system + chrome (`GreenHero`, `PageShell`, `AppCard`, `StatusBadge`, `Stars`, `AppField`, etc.). Navegação por `context.push` com objetos via `extra` (padrão adotado no 4A). Inclui os **disclaimers** do TCC: RF012 (benefícios) e RF037 (vagas/concursos).

**Tech Stack:** flutter_riverpod, go_router. Sem novas dependências.

**Fonte de design:** `design_reference/project/universe/screens-benefits.jsx` (BenefitsScreen, BenefitDetailScreen) e `screens-estagio.jsx` (EstagioScreen, VagaCard, DepoCard, DepoimentosScreen, VagaDetailScreen, ConcursoDetailScreen).

**Pré-requisitos prontos:** modelos `Benefit`/`BenefitKind`, `Internship` (RF033/RF034), `Contest` (RF036), `Testimonial`; `UniverseRepository` (`benefits(kind)`, `internships(courseFilter:)`, `contests()`, `testimonials()`, `internship(id)`, `contest(id)`); `courseShortLabels` (lib/data/courses.dart); design system; router com `context.push` + `extra`.

**Decisão de layout:** Benefícios = **cards** (decisão da spec: layout fixo).

---

## Estrutura de arquivos (Plano 4B)

```
lib/features/benefits/screens/benefits_screen.dart        BenefitsScreen(kind)
lib/features/benefits/screens/benefit_detail_screen.dart  BenefitDetailScreen
lib/features/internships/screens/estagio_screen.dart      EstagioScreen (abas+filtro+depoimentos)
lib/features/internships/screens/vaga_detail_screen.dart  VagaDetailScreen (RF033/RF034/RF037)
lib/features/internships/screens/contest_detail_screen.dart ConcursoDetailScreen (RF037)
lib/features/internships/screens/depoimentos_screen.dart  DepoimentosScreen (RF032)
lib/core/router/app_router.dart                           MODIFICA: novas rotas
lib/features/home/screens/home_screen.dart                MODIFICA: habilita rotas (_pushRoutes)
lib/features/courses/screens/course_detail_screen.dart    MODIFICA: "ver estágios" abre /estagio
```

---

### Task 1: Benefícios — lista (gov/inst) + detalhe

**Files:** Create `lib/features/benefits/screens/benefits_screen.dart`, `benefit_detail_screen.dart`

BenefitsScreen: `GreenHero` (título/subtítulo/ícone conforme `kind`), parágrafo introdutório,
**cards** (ícone + título + tag + descrição em 2 linhas) → abre detalhe via `extra`.
Inclui um aviso **RF012** ao final ("O app não cria nem gere benefícios…").
BenefitDetailScreen: "O que é" (descrição) + "Como solicitar" (passos numerados) + botão
"Acessar portal oficial" (toast) + link "Tenho uma dúvida" (abre /duvidas via go).

- [ ] **Step 1: BenefitsScreen**

`lib/features/benefits/screens/benefits_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/benefit.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/icon_tile.dart';

class BenefitsScreen extends ConsumerWidget {
  final BenefitKind kind;
  const BenefitsScreen({super.key, required this.kind});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final isGov = kind == BenefitKind.gov;
    final items = ref.watch(universeRepositoryProvider).benefits(kind);
    final intro = isGov
        ? 'Conheça os principais benefícios oferecidos pelo governo a estudantes. Toque para ver como solicitar.'
        : 'O IFSP oferece auxílios e bolsas para apoiar sua permanência e desenvolvimento acadêmico.';

    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(
        title: isGov ? 'Benefícios Governamentais' : 'Benefícios Institucionais',
        subtitle: isGov ? 'Programas e auxílios do governo' : 'Auxílios e bolsas do IFSP',
        icon: isGov ? 'benefits' : 'award',
        onBack: () => context.pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(intro, style: TextStyle(fontSize: 13, height: 1.55, color: c.ink2)),
          const SizedBox(height: 16),
          for (final b in items) Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              onTap: () => context.push('/beneficios/detail', extra: (benefit: b, isGov: isGov)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  IconTile(b.icon, size: 46),
                  const SizedBox(width: 13),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(b.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: c.green050, borderRadius: BorderRadius.circular(999)),
                      child: Text(b.tag, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c.green700)),
                    ),
                  ])),
                  Icon(appIcon('chevR'), size: 18, color: c.ink3),
                ]),
                const SizedBox(height: 10),
                Text(b.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5, height: 1.5, color: c.ink2)),
              ]),
            ),
          ),
          const SizedBox(height: 4),
          // RF012 — o app não cria/gere benefícios
          _Disclaimer('O app apenas informa os benefícios — não realiza a inscrição nem gerencia os programas. Dúvidas e solicitações devem ser feitas pelos canais oficiais do campus.'),
        ]),
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  final String text;
  const _Disclaimer(this.text);
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: c.bg2, borderRadius: BorderRadius.circular(12)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(appIcon('shield'), size: 16, color: c.ink3),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(fontSize: 11.5, height: 1.45, color: c.ink3))),
      ]),
    );
  }
}
```

- [ ] **Step 2: BenefitDetailScreen**

`lib/features/benefits/screens/benefit_detail_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/benefit.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_title.dart';

class BenefitDetailScreen extends StatelessWidget {
  final Benefit? benefit;
  final bool isGov;
  const BenefitDetailScreen({super.key, required this.benefit, required this.isGov});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final b = benefit;
    if (b == null) {
      return PageShell(
        bodyPadding: EdgeInsets.zero,
        header: PageHeader(title: 'Benefício', onBack: () => context.pop()),
        body: const EmptyState(icon: 'doc', title: 'Benefício não encontrado'),
      );
    }
    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(
        title: b.title,
        subtitle: isGov ? 'Benefício governamental' : 'Benefício institucional',
        icon: b.icon,
        onBack: () => context.pop(),
        child: Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Align(alignment: Alignment.centerLeft, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(999)),
            child: Text(b.tag, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
          )),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('O que é'),
          AppCard(child: Text(b.description, style: TextStyle(fontSize: 13.5, height: 1.6, color: c.ink2))),
          const SizedBox(height: 18),
          const SectionTitle('Como solicitar'),
          for (var i = 0; i < b.steps.length; i++) Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 28, height: 28, alignment: Alignment.center,
                decoration: BoxDecoration(color: c.green800, shape: BoxShape.circle),
                child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 13),
              Expanded(child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(b.steps[i], style: TextStyle(fontSize: 13.5, height: 1.45, color: c.ink)),
              )),
            ]),
          ),
          const SizedBox(height: 10),
          AppButton('Acessar portal oficial', full: true, icon: 'globe',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abrindo portal oficial… (em breve)')))),
          const SizedBox(height: 8),
          Center(child: TextButton(
            onPressed: () => context.go('/duvidas'),
            child: Text('Tenho uma dúvida sobre isso', style: TextStyle(fontWeight: FontWeight.w700, color: c.green700)),
          )),
        ]),
      ),
    );
  }
}
```

- [ ] **Step 3:** `flutter analyze lib/features/benefits/` — sem erros.
- [ ] **Step 4:** Commit — `git add lib/features/benefits/ && git commit -m "feat(benefits): telas de beneficios (gov/inst) e detalhe (RF012)"`

---

### Task 2: Estágio/Concursos — tela principal (abas + filtro + depoimentos)

**Files:** Create `lib/features/internships/screens/estagio_screen.dart`

`GreenHero` "Estágio e Concursos" com ação shield (admin → toast "em breve"). Toggle de
abas Estágios/Concursos. Na aba Estágios: chips de filtro por curso (`courseShortLabels`),
lista de `VagaCard` (cargo, status/tag, empresa, modalidade·bolsa·curso), e carrossel de
depoimentos com "Ver todos". Aba Concursos: cards de concurso (cargo, status, vagas·salário·prazo).
`EstagioScreen` aceita filtro inicial de curso (via `extra` ao vir do detalhe do curso).

- [ ] **Step 1: EstagioScreen**

`lib/features/internships/screens/estagio_screen.dart`:
```dart
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
        Expanded(child: Text('“${t.text}”', maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, height: 1.5, color: c.ink2))),
      ]),
    );
  }
}
```

> `GreenHero` precisa aceitar um `action` opcional (canto superior direito). Se ainda não
> aceitar, ADICIONE o parâmetro `Widget? action` ao `GreenHero` em
> `lib/shared/chrome/app_headers.dart` e renderize-o à direita da linha do botão voltar
> (Row: back + Spacer + action). Ajuste mínimo, sem quebrar usos existentes.

- [ ] **Step 2:** Se necessário, adicionar `action` ao `GreenHero` (ver nota). `flutter analyze lib/features/internships/estagio_screen.dart lib/shared/chrome/app_headers.dart` — sem erros.
- [ ] **Step 3:** Commit — `git add lib/features/internships/screens/estagio_screen.dart lib/shared/chrome/app_headers.dart && git commit -m "feat(estagio): tela de estagios/concursos (abas, filtro, depoimentos)"`

---

### Task 3: Detalhe de vaga (RF033/RF034/RF037) e de concurso (RF037)

**Files:** Create `lib/features/internships/screens/vaga_detail_screen.dart`, `contest_detail_screen.dart`

VagaDetail: `GreenHero` com status; banner RF034 se encerrada; grade de metadados
(modalidade, bolsa, carga/duração); Benefícios (chips); Pré-requisitos; Diferenciais;
Sobre a empresa; descrição da vaga; **disclaimer RF037**; botão candidatar (ou "encerrada").
ConcursoDetail: metadados (vagas, salário, escolaridade, prazo), sobre, disclaimer RF037, botão edital.

- [ ] **Step 1: VagaDetailScreen**

`lib/features/internships/screens/vaga_detail_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/internship.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/icon_tile.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/status_badge.dart';

class VagaDetailScreen extends StatelessWidget {
  final Internship? vaga;
  const VagaDetailScreen({super.key, required this.vaga});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final e = vaga;
    if (e == null) {
      return PageShell(
        bodyPadding: EdgeInsets.zero,
        header: PageHeader(title: 'Vaga', onBack: () => context.pop()),
        body: const EmptyState(icon: 'briefcase', title: 'Vaga não encontrada'),
      );
    }
    final closed = !e.open;
    final meta = [('Modalidade', e.mode), ('Bolsa', '${e.grant}/mês'), ('Duração', e.duration)];

    Widget block(String title, List<String> items, String icon, {bool muted = false}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionTitle(title),
        AppCard(child: Column(children: [
          for (final r in items) Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(appIcon(icon), size: 18, color: muted ? c.ink3 : c.green500),
              const SizedBox(width: 11),
              Expanded(child: Text(r, style: TextStyle(fontSize: 13.5, height: 1.45, color: muted ? c.ink2 : c.ink))),
            ]),
          ),
        ])),
        const SizedBox(height: 16),
      ],
    );

    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(
        title: e.role, subtitle: '${e.companyName} · ${e.area}', icon: 'briefcase', onBack: () => context.pop(),
        child: Padding(padding: const EdgeInsets.only(top: 14), child: Align(alignment: Alignment.centerLeft, child: StatusBadge(closed: closed))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (closed) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: c.error.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Icon(appIcon('clock'), size: 20, color: c.error),
                const SizedBox(width: 11),
                Expanded(child: Text('Esta vaga está encerrada. Mantemos visível por 1 mês como referência.',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.4, color: c.error))),
              ]),
            ),
            const SizedBox(height: 16),
          ],
          GridView.count(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, childAspectRatio: 2.6, mainAxisSpacing: 10, crossAxisSpacing: 10,
            children: [
              for (final (k, v) in meta) AppCard(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(k, style: TextStyle(fontSize: 11, color: c.ink3, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(v, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink)),
              ])),
            ],
          ),
          const SizedBox(height: 18),
          const SectionTitle('Descrição da vaga'),
          AppCard(child: Text(e.jobDescription, style: TextStyle(fontSize: 13.5, height: 1.6, color: c.ink2))),
          const SizedBox(height: 16),
          if (e.benefits.isNotEmpty) ...[
            const SectionTitle('Benefícios'),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final b in e.benefits) Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                decoration: BoxDecoration(color: c.green050, borderRadius: BorderRadius.circular(999)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(appIcon('check'), size: 14, color: c.green600),
                  const SizedBox(width: 6),
                  Text(b, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.green700)),
                ]),
              ),
            ]),
            const SizedBox(height: 18),
          ],
          if (e.requirements.isNotEmpty) block('Pré-requisitos', e.requirements, 'checkCircle'),
          if (e.niceToHave.isNotEmpty) block('Diferenciais desejáveis', e.niceToHave, 'check', muted: true),
          const SectionTitle('Sobre a empresa'),
          AppCard(child: Text(e.companyDescription, style: TextStyle(fontSize: 13.5, height: 1.6, color: c.ink2))),
          const SizedBox(height: 16),
          // RF037 — o app só divulga
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: c.bg2, borderRadius: BorderRadius.circular(12)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(appIcon('shield'), size: 16, color: c.ink3),
              const SizedBox(width: 8),
              Expanded(child: Text('O app apenas divulga a vaga. O processo seletivo é conduzido pela empresa responsável.',
                  style: TextStyle(fontSize: 11.5, height: 1.45, color: c.ink3))),
            ]),
          ),
          const SizedBox(height: 16),
          if (closed)
            const AppButton('Vaga encerrada', full: true, variant: AppButtonVariant.ghost)
          else
            AppButton('Quero me candidatar', full: true, icon: 'send',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Abrindo ${e.link ?? 'a vaga'}… (em breve)')))),
          if (e.link != null) Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Center(child: Text('Você será direcionado para ${e.link}', style: TextStyle(fontSize: 11.5, color: c.ink3))),
          ),
        ]),
      ),
    );
  }
}
```

- [ ] **Step 2: ConcursoDetailScreen**

`lib/features/internships/screens/contest_detail_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/contest.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/icon_tile.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/status_badge.dart';

class ConcursoDetailScreen extends StatelessWidget {
  final Contest? contest;
  const ConcursoDetailScreen({super.key, required this.contest});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final ct = contest;
    if (ct == null) {
      return PageShell(
        bodyPadding: EdgeInsets.zero,
        header: PageHeader(title: 'Concurso', onBack: () => context.pop()),
        body: const EmptyState(icon: 'doc', title: 'Concurso não encontrado'),
      );
    }
    final open = ct.isOpenAt(DateTime.now());
    final prazo = '${ct.deadline.day.toString().padLeft(2, '0')}/${ct.deadline.month.toString().padLeft(2, '0')}/${ct.deadline.year}';
    final meta = [('Vagas', ct.vagas), ('Salário', ct.salary), ('Escolaridade', ct.level), ('Inscrições até', prazo)];

    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(
        title: ct.role, subtitle: ct.org, icon: 'doc', onBack: () => context.pop(),
        child: Padding(padding: const EdgeInsets.only(top: 14), child: Align(alignment: Alignment.centerLeft,
          child: StatusBadge(closed: !open, openLabel: 'Inscrições abertas', closedLabel: 'Inscrições encerradas'))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GridView.count(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, childAspectRatio: 2.6, mainAxisSpacing: 10, crossAxisSpacing: 10,
            children: [
              for (final (k, v) in meta) AppCard(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(k, style: TextStyle(fontSize: 11, color: c.ink3, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(v, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink)),
              ])),
            ],
          ),
          const SizedBox(height: 18),
          const SectionTitle('Sobre o concurso'),
          AppCard(child: Text(ct.about, style: TextStyle(fontSize: 13.5, height: 1.6, color: c.ink2))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: c.bg2, borderRadius: BorderRadius.circular(12)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(appIcon('shield'), size: 16, color: c.ink3),
              const SizedBox(width: 8),
              Expanded(child: Text('O app apenas divulga o edital. Inscrições e seleção são de responsabilidade do órgão organizador.',
                  style: TextStyle(fontSize: 11.5, height: 1.45, color: c.ink3))),
            ]),
          ),
          const SizedBox(height: 16),
          if (open)
            AppButton('Acessar edital', full: true, icon: 'doc',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abrindo edital… (em breve)'))))
          else
            const AppButton('Inscrições encerradas', full: true, variant: AppButtonVariant.ghost),
        ]),
      ),
    );
  }
}
```

- [ ] **Step 3:** `flutter analyze lib/features/internships/` — sem erros.
- [ ] **Step 4:** Commit — `git add lib/features/internships/screens/vaga_detail_screen.dart lib/features/internships/screens/contest_detail_screen.dart && git commit -m "feat(estagio): detalhe de vaga (RF033/RF034/RF037) e de concurso (RF037)"`

---

### Task 4: DepoimentosScreen (RF032)

**Files:** Create `lib/features/internships/screens/depoimentos_screen.dart`

Lista de depoimentos (todos do repo) + formulário para o aluno **publicar** o seu (org,
nota em estrelas, texto). Publicação adiciona à lista **em memória** nesta fase (persistência
real virá na fase de dados). Usa o nome do usuário autenticado.

- [ ] **Step 1: DepoimentosScreen**

`lib/features/internships/screens/depoimentos_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/testimonial.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_field.dart';
import '../../../shared/widgets/stars.dart';
import '../../../shared/widgets/user_avatar.dart';

class DepoimentosScreen extends ConsumerStatefulWidget {
  const DepoimentosScreen({super.key});
  @override
  ConsumerState<DepoimentosScreen> createState() => _DepoimentosScreenState();
}

class _DepoimentosScreenState extends ConsumerState<DepoimentosScreen> {
  final List<Testimonial> _added = [];
  bool _adding = false;
  String _org = '', _text = '';
  int _stars = 5;

  void _submit() {
    final user = ref.read(authStateProvider).valueOrNull;
    setState(() {
      _added.insert(0, Testimonial(
        name: user?.name ?? 'Estudante',
        course: (user?.name ?? '').isEmpty ? 'IFSP' : 'IFSP',
        org: _org, stars: _stars, text: _text,
      ));
      _adding = false; _org = ''; _text = ''; _stars = 5;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Depoimento publicado!')));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final all = [..._added, ...ref.watch(universeRepositoryProvider).testimonials()];
    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(title: 'Depoimentos', subtitle: 'Quem já estagiou conta como foi', icon: 'star', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!_adding)
            AppButton('Adicionar meu depoimento', full: true, icon: 'edit', onTap: () => setState(() => _adding = true))
          else
            AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Seu depoimento', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: c.ink)),
              const SizedBox(height: 12),
              AppField(label: 'Onde você estagiou?', icon: 'institution', value: _org, onChanged: (v) => setState(() => _org = v), hint: 'Empresa / órgão'),
              const SizedBox(height: 12),
              Text('Sua nota', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.ink2)),
              const SizedBox(height: 7),
              Row(children: [
                for (var s = 1; s <= 5; s++) GestureDetector(
                  onTap: () => setState(() => _stars = s),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(s <= _stars ? Icons.star : Icons.star_border, size: 28, color: s <= _stars ? c.star : c.line),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              AppField(label: 'Como foi a experiência?', value: _text, onChanged: (v) => setState(() => _text = v), hint: 'Conte para os colegas…'),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: AppButton('Cancelar', full: true, variant: AppButtonVariant.ghost, onTap: () => setState(() => _adding = false))),
                const SizedBox(width: 10),
                Expanded(child: AppButton('Publicar', full: true, icon: 'check',
                  onTap: (_org.trim().length >= 2 && _text.trim().length >= 10) ? _submit : null)),
              ]),
            ])),
          const SizedBox(height: 16),
          for (final t in all) Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                UserAvatar(t.name, size: 40),
                const SizedBox(width: 11),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t.name, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink)),
                  Text('${t.course} · ${t.org}', style: TextStyle(fontSize: 11, color: c.ink3)),
                ])),
              ]),
              const SizedBox(height: 9),
              Stars(t.stars),
              const SizedBox(height: 9),
              Text('“${t.text}”', style: TextStyle(fontSize: 12.5, height: 1.5, color: c.ink2)),
            ])),
          ),
        ]),
      ),
    );
  }
}
```

> Nota: `course` do depoimento do aluno fica como 'IFSP' provisoriamente; quando o
> perfil (curso) estiver carregado globalmente, usar o curso real. Mantido simples aqui.

- [ ] **Step 2:** `flutter analyze lib/features/internships/screens/depoimentos_screen.dart` — sem erros (remova o ternário redundante de `course` se o analyzer apontar — pode usar `'IFSP'` direto).
- [ ] **Step 3:** Commit — `git add lib/features/internships/screens/depoimentos_screen.dart && git commit -m "feat(estagio): tela de depoimentos com publicacao (RF032)"`

---

### Task 5: Ligar rotas + habilitar navegação

**Files:** Modify `lib/core/router/app_router.dart`, `lib/features/home/screens/home_screen.dart`, `lib/features/courses/screens/course_detail_screen.dart`

- [ ] **Step 1: Router** — adicionar imports e rotas top-level (todas full-screen, fora do ShellRoute):
```dart
import '../../data/models/benefit.dart';
import '../../data/models/internship.dart';
import '../../data/models/contest.dart';
import '../../features/benefits/screens/benefits_screen.dart';
import '../../features/benefits/screens/benefit_detail_screen.dart';
import '../../features/internships/screens/estagio_screen.dart';
import '../../features/internships/screens/vaga_detail_screen.dart';
import '../../features/internships/screens/contest_detail_screen.dart';
import '../../features/internships/screens/depoimentos_screen.dart';
```
Rotas:
```dart
GoRoute(path: '/beneficios/gov', builder: (c, s) => const BenefitsScreen(kind: BenefitKind.gov)),
GoRoute(path: '/beneficios/inst', builder: (c, s) => const BenefitsScreen(kind: BenefitKind.inst)),
GoRoute(path: '/beneficios/detail', builder: (c, s) {
  final x = s.extra;
  if (x is ({Benefit benefit, bool isGov})) return BenefitDetailScreen(benefit: x.benefit, isGov: x.isGov);
  return const BenefitDetailScreen(benefit: null, isGov: true);
}),
GoRoute(path: '/estagio', builder: (c, s) => EstagioScreen(initialCourse: s.extra is String ? s.extra as String : 'Todos')),
GoRoute(path: '/estagio/vaga', builder: (c, s) => VagaDetailScreen(vaga: s.extra is Internship ? s.extra as Internship : null)),
GoRoute(path: '/estagio/concurso', builder: (c, s) => ConcursoDetailScreen(contest: s.extra is Contest ? s.extra as Contest : null)),
GoRoute(path: '/estagio/depoimentos', builder: (c, s) => const DepoimentosScreen()),
```
Atualizar o `onNavigate` do drawer para usar `push` nas novas rotas (benefícios, estágio):
trocar a condição `else if (route == '/ifsp')` por
`else if (route == '/ifsp' || route == '/beneficios/gov' || route == '/beneficios/inst' || route == '/estagio')`.

- [ ] **Step 2: HomeScreen** — em `_pushRoutes`, adicionar as novas rotas:
```dart
  static const _pushRoutes = {'/ifsp', '/beneficios/gov', '/beneficios/inst', '/estagio'};
```
(Assim os itens "Explorar" e o card de destaque deixam de mostrar "Em breve" e navegam.)

- [ ] **Step 3: CourseDetailScreen** — o botão "Ver estágios para este curso" deve abrir
`/estagio` filtrando pelo curso. Importar `courseShort` de `lib/data/courses.dart` e trocar
o onTap do `AppButton`:
```dart
onTap: () => context.push('/estagio', extra: courseShort(course.name)),
```

- [ ] **Step 4:** `flutter analyze` — limpo. `flutter test` — toda a suíte PASS.
- [ ] **Step 5:** Commit — `git add lib/ && git commit -m "feat(nav): liga beneficios e estagio/concursos no router"`

---

### Task 6: Verificação + diário

- [ ] **Step 1:** `flutter analyze` (limpo) + `flutter test` (tudo PASS).
- [ ] **Step 2:** Rodar no navegador; conferir: Benefícios gov/inst + detalhe (passos + disclaimer); Estágio (filtro por curso, abas, depoimentos); detalhe de vaga (campos RF033, banner se encerrada, disclaimer RF037); concurso; publicar depoimento; "Ver estágios para este curso" filtra.
- [ ] **Step 3:** Entrada no diário resumindo o 4B (com RF012/RF037/RF032).
- [ ] **Step 4:** Commit — `git add docs/ && git commit -m "docs: registra Plano 4B (Beneficios e Estagio/Concursos)"`

---

## Self-Review
- **Benefícios gov/inst + detalhe:** cards, passos "como solicitar", **disclaimer RF012** — Task 1.
- **Estágio/Concursos:** abas, filtro por curso (RF031), cards, depoimentos — Task 2.
- **Detalhe de vaga:** 10 campos do RF033 (incl. descrição da vaga e da empresa separadas), banner RF034 (encerrada 1 mês), **disclaimer RF037** — Task 3.
- **Concurso:** metadados + prazo + disclaimer RF037 — Task 3.
- **Depoimentos (RF032):** lista + publicação pelo aluno — Task 4.
- **Navegação:** push + extra; Home/drawer habilitam as rotas; curso→estágio filtra — Task 5.

**Riscos/notas:**
1. `GreenHero` pode precisar do parâmetro `action` (Task 2) — ajuste mínimo, manter usos atuais.
2. Publicação de depoimento é **em memória** nesta fase (persistência na fase de dados).
3. Records como `extra` (`({Benefit benefit, bool isGov})`) — manter o mesmo shape no push (BenefitsScreen) e no builder (router).
