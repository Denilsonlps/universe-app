import 'package:flutter/material.dart';
import '../../shared/chrome/page_shell.dart';
import '../../shared/chrome/app_headers.dart';
import '../../shared/chrome/bottom_nav.dart';
import '../../shared/widgets/empty_state.dart';

/// Tela temporária — substituída pelas telas reais no Plano 3.
class PlaceholderScreen extends StatelessWidget {
  final String title, tab;
  final VoidCallback onMenu, onBell;
  final ValueChanged<String> onTab;
  const PlaceholderScreen({super.key, required this.title, required this.tab, required this.onMenu, required this.onBell, required this.onTab});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      header: HomeHeader(onMenu: onMenu, onBell: onBell),
      bottomNav: AppBottomNav(current: tab, onTap: onTab),
      body: EmptyState(icon: 'doc', title: title, body: 'Tela em construção (Plano 3).'),
    );
  }
}
