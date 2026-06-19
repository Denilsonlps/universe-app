import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/icon_tile.dart';

/// Ícones oferecidos ao admin para representar uma página de conteúdo.
const contentIconChoices = <String>[
  'card', 'user', 'bus', 'doc', 'benefits', 'award', 'book', 'globe',
  'institution', 'briefcase', 'flag', 'star', 'shield', 'phone', 'mail', 'cap', 'house', 'settings',
];

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
