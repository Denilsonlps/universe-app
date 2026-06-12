# Plano 3.5 — Identidade Visual (marca Universe)

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`).

**Goal:** Portar o sistema de marca do protótipo (`brand.jsx`) para widgets Flutter vetoriais e aplicá-los onde hoje aparece o texto simples "UNIVERSE".

**Architecture:** Um arquivo `lib/shared/brand/universe_brand.dart` com 4 widgets: `UniverseMark` e `UniverseBadge` (CustomPainter, geometria exata do SVG), `UniverseAppIcon` (squircle com gradiente + sweep + mark), `UniverseWordmark` (UNI + mark + RSE em Montserrat 800). Sem dependência de PNG; cor parametrizável (tema claro/escuro).

**Fonte:** `design_reference/project/universe/brand.jsx`. Substitui `Text('UNIVERSE')` em `app_headers.dart` (HomeHeader), `menu_drawer.dart`, `login_screen.dart`, `splash_screen.dart`.

---

### Task 1: Widgets de marca + teste

**Files:** Create `lib/shared/brand/universe_brand.dart`, Test `test/widgets/universe_brand_test.dart`

- [ ] **Step 1: Criar os widgets**

`lib/shared/brand/universe_brand.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// O "mark" da Universe: chevron em V (capelo/visto) coroado por um ponto
/// (cabeça do formando). Geometria portada de brand.jsx (viewBox 64×64).
class UniverseMark extends StatelessWidget {
  final double size;
  final Color color;
  final Color? dotColor;
  const UniverseMark({super.key, this.size = 64, this.color = const Color(0xFF00573A), this.dotColor});

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: size, height: size, child: CustomPaint(painter: _MarkPainter(color, dotColor ?? color)));
}

class _MarkPainter extends CustomPainter {
  final Color color, dotColor;
  _MarkPainter(this.color, this.dotColor);
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 64.0;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(13 * s, 17 * s)
      ..lineTo(32 * s, 51 * s)
      ..lineTo(51 * s, 17 * s);
    canvas.drawPath(path, stroke);
    canvas.drawCircle(Offset(32 * s, 12.5 * s), 7 * s, Paint()..color = dotColor);
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.color != color || old.dotColor != dotColor;
}

/// Selo circular (monograma do mark). Geometria de brand.jsx (viewBox 44×44).
class UniverseBadge extends StatelessWidget {
  final double size;
  final Color color;
  final Color? ring;
  const UniverseBadge({super.key, this.size = 44, this.color = const Color(0xFF1FA971), this.ring});

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: size, height: size, child: CustomPaint(painter: _BadgePainter(color, ring ?? color)));
}

class _BadgePainter extends CustomPainter {
  final Color color, ring;
  _BadgePainter(this.color, this.ring);
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 44.0;
    canvas.drawCircle(
      Offset(22 * s, 22 * s), 20 * s,
      Paint()..color = ring.withValues(alpha: 0.55)..style = PaintingStyle.stroke..strokeWidth = 2.4 * s,
    );
    final v = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.4 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()..moveTo(13 * s, 18 * s)..lineTo(22 * s, 34 * s)..lineTo(31 * s, 18 * s), v,
    );
    canvas.drawCircle(Offset(22 * s, 13.5 * s), 3.4 * s, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_BadgePainter old) => old.color != color || old.ring != ring;
}

/// Ícone do app: squircle verde com gradiente, brilho e o mark em branco.
class UniverseAppIcon extends StatelessWidget {
  final double size;
  final double? radius;
  const UniverseAppIcon({super.key, this.size = 96, this.radius});

  @override
  Widget build(BuildContext context) {
    final r = radius ?? size * 0.235;
    return Container(
      width: size, height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        gradient: const LinearGradient(
          begin: Alignment.topRight, end: Alignment.bottomLeft,
          colors: [Color(0xFF00734D), Color(0xFF00573A), Color(0xFF003D28)], stops: [0, 0.55, 1],
        ),
      ),
      child: Stack(alignment: Alignment.center, children: [
        Positioned(
          top: -size * 0.35, left: -size * 0.2,
          child: Container(
            width: size * 0.9, height: size * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [const Color(0xFF26C17D).withValues(alpha: 0.55), Colors.transparent], stops: const [0, 0.7]),
            ),
          ),
        ),
        UniverseMark(size: size * 0.62, color: Colors.white, dotColor: const Color(0xFF26C17D)),
      ]),
    );
  }
}

/// Wordmark completo: UNI + mark + RSE, recriado em tipografia (Montserrat 800).
class UniverseWordmark extends StatelessWidget {
  final double height;
  final Color color;
  const UniverseWordmark({super.key, this.height = 28, this.color = const Color(0xFF00573A)});

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.montserrat(
      fontSize: height, fontWeight: FontWeight.w800, letterSpacing: height * 0.02, color: color, height: 1,
    );
    return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text('UNI', style: style),
      UniverseMark(size: height * 1.18, color: color, dotColor: color),
      Text('RSE', style: style),
    ]);
  }
}
```

- [ ] **Step 2: Teste de fumaça (claro e escuro)**

`test/widgets/universe_brand_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/shared/brand/universe_brand.dart';

void main() {
  testWidgets('marca renderiza sem exceções', (t) async {
    await t.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Column(children: [
          UniverseMark(size: 64),
          UniverseBadge(size: 44),
          UniverseAppIcon(size: 96),
          UniverseWordmark(height: 28),
        ]),
      ),
    ));
    expect(find.byType(UniverseMark), findsWidgets);
    expect(find.byType(UniverseAppIcon), findsOneWidget);
    expect(find.text('UNI'), findsOneWidget);
    expect(find.text('RSE'), findsOneWidget);
  });
}
```

- [ ] **Step 3:** `flutter test test/widgets/universe_brand_test.dart` (PASS) + `flutter analyze lib/shared/brand/` (limpo).
- [ ] **Step 4:** Commit — `git add lib/shared/brand/ test/widgets/universe_brand_test.dart && git commit -m "feat(brand): widgets vetoriais da marca Universe (mark, badge, app icon, wordmark)"`

---

### Task 2: Aplicar a marca nas telas

**Files:** Modify `lib/shared/chrome/app_headers.dart`, `lib/shared/chrome/menu_drawer.dart`, `lib/features/auth/screens/login_screen.dart`, `lib/features/auth/screens/splash_screen.dart`

Substituir cada `Text('UNIVERSE', ...)` pelo widget de marca adequado. Importar
`package:universe_app/shared/brand/universe_brand.dart` em cada arquivo.

- [ ] **Step 1: HomeHeader** (`app_headers.dart`): trocar o `Text('UNIVERSE', …)` central por `UniverseWordmark(height: 22, color: c.green800)`.

- [ ] **Step 2: MenuDrawer** (`menu_drawer.dart`): no cabeçalho verde, trocar o `Text('UNIVERSE', …)` por uma linha com o ícone + wordmark branco:
```dart
Row(children: [
  const UniverseAppIcon(size: 40),
  const SizedBox(width: 12),
  const UniverseWordmark(height: 20, color: Colors.white),
]),
```
(substituindo o `Text('UNIVERSE'…)` atual; manter o restante do cabeçalho.)

- [ ] **Step 3: LoginScreen** (`login_screen.dart`): no topo, substituir o `Text('UNIVERSE', …)` por:
```dart
const UniverseAppIcon(size: 72),
const SizedBox(height: 16),
const UniverseWordmark(height: 26, color: Colors.white),
```
(manter o subtítulo "Guia do estudante · IFSP Pirituba" abaixo.)

- [ ] **Step 4: SplashScreen** (`splash_screen.dart`): substituir o `Text('UNIVERSE', …)` por:
```dart
const UniverseAppIcon(size: 96),
const SizedBox(height: 22),
const UniverseWordmark(height: 30, color: Colors.white),
```
(acima do `CircularProgressIndicator`).

- [ ] **Step 5:** `flutter analyze` (limpo) + `flutter test` (toda a suíte PASS — os testes que procuram `find.text('UNIVERSE')` foram do Plano 1? Verificar: o smoke test do app procura 'UNIVERSE'? Em widget_test.dart o teste do Plano 2 procura 'Próximo', e o navigation_test procura 'IFSP Pirituba'/'Cursos'. Se algum teste ainda buscar o texto literal 'UNIVERSE', atualizar para `find.byType(UniverseWordmark)`).
- [ ] **Step 6:** Commit — `git add -A && git commit -m "feat(brand): aplica a marca Universe em header, drawer, login e splash"`

---

### Task 3: Verificação + diário

- [ ] **Step 1:** `flutter analyze` (limpo) e `flutter test` (tudo PASS).
- [ ] **Step 2:** Entrada no diário resumindo a identidade visual aplicada.
- [ ] **Step 3:** Commit — `git add docs/ && git commit -m "docs: registra identidade visual (marca Universe)"`

---

## Self-Review
- Marca portada fielmente do `brand.jsx` (geometria exata do mark/badge; gradiente do app icon; wordmark UNI+mark+RSE) — Task 1.
- Aplicada em todos os pontos que usavam texto simples — Task 2.
- Cor parametrizável → funciona em tema claro e escuro.
- Sem dependência de PNG; o logo institucional (ifsp-logo.png) é separado e entra na tela do campus (Plano 4).

**Nota:** verificar testes que buscavam `find.text('UNIVERSE')` literal e migrar para `find.byType(UniverseWordmark)`.
