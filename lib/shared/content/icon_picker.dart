import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/icon_tile.dart';

/// Ícones oferecidos ao admin para representar uma página de conteúdo.
const contentIconChoices = <String>[
  'card', 'user', 'bus', 'doc', 'benefits', 'award', 'book', 'globe',
  'institution', 'briefcase', 'flag', 'star', 'shield', 'phone', 'mail', 'cap', 'house', 'settings',
  'heart', 'wallet', 'calendar', 'people', 'laptop', 'health', 'food', 'sports',
  'music', 'wifi', 'lock', 'gift', 'science', 'camera', 'chat', 'money', 'ticket',
  'lightbulb', 'rocket', 'map', 'handshake',
];

/// Abre um menu suspenso (bottom sheet) com todos os ícones e devolve o escolhido.
Future<String?> showIconPickerSheet(BuildContext context, String selected) {
  final c = context.c;
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: c.card,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: c.line, borderRadius: BorderRadius.circular(999)))),
        const SizedBox(height: 16),
        Text('Escolha um ícone', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: c.ink)),
        const SizedBox(height: 16),
        Flexible(
          child: SingleChildScrollView(
            child: IconPicker(selected: selected, onSelect: (n) => Navigator.pop(ctx, n)),
          ),
        ),
      ]),
    ),
  );
}

/// Grid de ícones selecionável (sem digitar nomes).
class IconPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const IconPicker({super.key, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Wrap(
      spacing: 10, runSpacing: 10,
      children: [
        for (final name in contentIconChoices)
          GestureDetector(
            onTap: () => onSelect(name),
            child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: name == selected ? c.green800 : c.bg2,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: name == selected ? c.green800 : c.line, width: 1.5),
              ),
              child: Icon(appIcon(name), size: 23, color: name == selected ? Colors.white : c.ink2),
            ),
          ),
      ],
    );
  }
}
