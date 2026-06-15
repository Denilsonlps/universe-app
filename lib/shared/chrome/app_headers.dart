import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../brand/universe_brand.dart';
import '../widgets/icon_tile.dart';
import 'page_shell.dart';

/// Header da Home: menu · wordmark · sino.
class HomeHeader extends StatelessWidget {
  final VoidCallback onMenu, onBell;
  final bool unread;
  const HomeHeader({super.key, required this.onMenu, required this.onBell, this.unread = true});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    Widget btn(String icon, VoidCallback onTap, {bool dot = false}) => InkWell(
      borderRadius: BorderRadius.circular(12), onTap: onTap,
      child: Container(
        width: 42, height: 42, alignment: Alignment.center,
        decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: const Color(0xFF0D281C).withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Stack(clipBehavior: Clip.none, children: [
          Icon(appIcon(icon), size: 22, color: c.ink),
          if (dot) Positioned(right: -2, top: -2, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: c.error, shape: BoxShape.circle))),
        ]),
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, kStatusH, 18, 14),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        btn('menu', onMenu),
        UniverseWordmark(height: 22, color: c.green800),
        btn('bell', onBell, dot: unread),
      ]),
    );
  }
}

/// Header simples com voltar + título.
class PageHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const PageHeader({super.key, required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, kStatusH, 12, 12),
      decoration: BoxDecoration(color: c.bg, border: Border(bottom: BorderSide(color: c.line))),
      child: Row(children: [
        InkWell(borderRadius: BorderRadius.circular(11), onTap: onBack, child: SizedBox(width: 40, height: 40, child: Icon(appIcon('chevL'), size: 24, color: c.ink))),
        const SizedBox(width: 6),
        Expanded(child: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: c.ink, letterSpacing: -0.2))),
      ]),
    );
  }
}

/// Header verde curvo para telas de detalhe.
class GreenHero extends StatelessWidget {
  final String title;
  final String? subtitle, icon;
  final VoidCallback onBack;
  final Widget? child;
  final Widget? action;
  const GreenHero({super.key, required this.title, this.subtitle, this.icon, required this.onBack, this.child, this.action});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, kStatusH, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c.heroFrom, c.heroTo]),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          InkWell(borderRadius: BorderRadius.circular(11), onTap: onBack, child: const SizedBox(width: 38, height: 38, child: Icon(Icons.chevron_left, size: 24, color: Colors.white))),
          const Spacer(),
          if (action != null) action!,
        ]),
        const SizedBox(height: 12),
        Row(children: [
          if (icon != null) ...[
            Container(width: 54, height: 54, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(15)), child: Icon(appIcon(icon!), size: 28, color: Colors.white)),
            const SizedBox(width: 14),
          ],
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
            if (subtitle != null) Padding(padding: const EdgeInsets.only(top: 5), child: Text(subtitle!, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.78), height: 1.4))),
          ])),
        ]),
        ?child,
      ]),
    );
  }
}
