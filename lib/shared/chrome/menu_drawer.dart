import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../brand/universe_brand.dart';
import '../widgets/icon_tile.dart';
import '../widgets/user_avatar.dart';
import 'page_shell.dart';

class DrawerItem {
  final String route, icon, label;
  const DrawerItem(this.route, this.icon, this.label);
}

const drawerItems = [
  DrawerItem('/home', 'home', 'Início'),
  DrawerItem('/ifsp', 'institution', 'IFSP Pirituba'),
  DrawerItem('/cursos', 'cap', 'Cursos'),
  DrawerItem('/beneficios/gov', 'benefits', 'Benefícios Governamentais'),
  DrawerItem('/beneficios/inst', 'award', 'Benefícios Institucionais'),
  DrawerItem('/estagio', 'briefcase', 'Estágio e Concursos'),
  DrawerItem('/duvidas', 'question', 'Dúvidas'),
];

class MenuDrawer extends StatelessWidget {
  final String userName, userEmail;
  final bool isAdmin;
  final ValueChanged<String> onNavigate;
  final VoidCallback onLogout;
  const MenuDrawer({super.key, required this.userName, required this.userEmail, this.isAdmin = false, required this.onNavigate, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Drawer(
      backgroundColor: c.bg,
      child: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, kStatusH + 6, 22, 22),
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c.heroFrom, c.heroTo])),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: const [
              UniverseAppIcon(size: 40),
              SizedBox(width: 12),
              UniverseWordmark(height: 20, color: Colors.white),
            ]),
            const SizedBox(height: 18),
            Row(children: [
              UserAvatar(userName, size: 46),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                Text(userEmail, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
              ])),
            ]),
          ]),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              for (final m in drawerItems)
                ListTile(
                  leading: Icon(appIcon(m.icon), color: c.green700),
                  title: Text(m.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.ink)),
                  trailing: Icon(appIcon('chevR'), size: 16, color: c.ink3),
                  onTap: () => onNavigate(m.route),
                ),
              if (isAdmin)
                ListTile(
                  leading: Icon(appIcon('shield'), color: c.green700),
                  title: Text('Painel de Administração', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.ink)),
                  trailing: Icon(appIcon('chevR'), size: 16, color: c.ink3),
                  onTap: () => onNavigate('/admin'),
                ),
              Divider(color: c.line),
              ListTile(
                leading: Icon(appIcon('logout'), color: c.error),
                title: Text('Sair', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.error)),
                onTap: onLogout,
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
