import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/icon_tile.dart';
import 'page_shell.dart';

class NavTab {
  final String key, icon, label;
  const NavTab(this.key, this.icon, this.label);
}

const navTabs = [
  NavTab('home', 'home', 'Início'),
  NavTab('cursos', 'cap', 'Cursos'),
  NavTab('duvidas', 'question', 'Dúvidas'),
  NavTab('perfil', 'user', 'Perfil'),
];

class AppBottomNav extends StatelessWidget {
  final String current;
  final ValueChanged<String> onTap;
  const AppBottomNav({super.key, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      height: kNavH + 22,
      padding: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(color: c.card, border: Border(top: BorderSide(color: c.line))),
      child: Row(children: [
        for (final t in navTabs)
          Expanded(
            child: InkWell(
              onTap: () => onTap(t.key),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(appIcon(t.icon), size: 23, color: current == t.key ? c.green700 : c.ink3),
                const SizedBox(height: 4),
                Text(t.label, style: TextStyle(fontSize: 10.5, fontWeight: current == t.key ? FontWeight.w700 : FontWeight.w600, color: current == t.key ? c.green700 : c.ink3)),
              ]),
            ),
          ),
      ]),
    );
  }
}
