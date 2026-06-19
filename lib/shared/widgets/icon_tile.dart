import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

const appIcons = <String, IconData>{
  'institution': Icons.account_balance, 'cap': Icons.school,
  'benefits': Icons.volunteer_activism, 'award': Icons.workspace_premium,
  'briefcase': Icons.work_outline, 'edit': Icons.edit_outlined,
  'house': Icons.home_work_outlined, 'question': Icons.help_outline,
  'card': Icons.badge_outlined, 'pin': Icons.place_outlined,
  'doc': Icons.description_outlined, 'book': Icons.menu_book_outlined,
  'globe': Icons.public, 'bus': Icons.directions_bus_outlined,
  'flag': Icons.flag_outlined, 'settings': Icons.settings_outlined,
  'user': Icons.person_outline, 'phone': Icons.call_outlined,
  'mail': Icons.mail_outline, 'clock': Icons.schedule, 'shield': Icons.shield_outlined,
  'search': Icons.search, 'bell': Icons.notifications_none, 'menu': Icons.menu,
  'star': Icons.star, 'home': Icons.home_outlined, 'logout': Icons.logout, 'check': Icons.check,
  'chevR': Icons.chevron_right, 'chevL': Icons.chevron_left, 'chevD': Icons.keyboard_arrow_down,
  'checkCircle': Icons.check_circle, 'plus': Icons.add, 'send': Icons.send,
  // Extras para o seletor de ícone das páginas de conteúdo
  'heart': Icons.favorite_outline, 'wallet': Icons.account_balance_wallet_outlined,
  'calendar': Icons.calendar_today_outlined, 'people': Icons.groups_outlined,
  'laptop': Icons.computer_outlined, 'health': Icons.health_and_safety_outlined,
  'food': Icons.restaurant_outlined, 'sports': Icons.sports_soccer_outlined,
  'music': Icons.music_note_outlined, 'wifi': Icons.wifi, 'lock': Icons.lock_outline,
  'gift': Icons.card_giftcard_outlined, 'science': Icons.science_outlined,
  'camera': Icons.photo_camera_outlined, 'chat': Icons.chat_bubble_outline,
  'money': Icons.payments_outlined, 'ticket': Icons.confirmation_number_outlined,
  'lightbulb': Icons.lightbulb_outline, 'rocket': Icons.rocket_launch_outlined,
  'map': Icons.map_outlined, 'handshake': Icons.handshake_outlined,
};

IconData appIcon(String name) => appIcons[name] ?? Icons.circle_outlined;

class IconTile extends StatelessWidget {
  final String name;
  final double size, iconSize, radius;
  final Color? bg, color;
  const IconTile(this.name, {super.key, this.size = 46, this.iconSize = 24, this.radius = 13, this.bg, this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: bg ?? c.green050, borderRadius: BorderRadius.circular(radius)),
      child: Icon(appIcon(name), size: iconSize, color: color ?? c.green700),
    );
  }
}
