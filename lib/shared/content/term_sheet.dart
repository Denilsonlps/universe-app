import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/content/glossary.dart';
import '../widgets/app_button.dart';
import '../widgets/icon_tile.dart';

/// Mostra a ficha de definição de um termo do glossário (bottom sheet).
Future<void> showTermSheet(BuildContext context, String termKey, {void Function(String docId)? onOpenDoc}) {
  final g = glossary[termKey];
  // Sem definição não há ficha a mostrar (entradas só-`docId` navegam direto).
  if (g == null || g.def == null) return Future.value();
  final c = context.c;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: c.card,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 30),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: c.line, borderRadius: BorderRadius.circular(999)))),
        const SizedBox(height: 18),
        Row(children: [
          IconTile('book', size: 42),
          const SizedBox(width: 11),
          Expanded(child: Text(g.term ?? termKey, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: c.ink))),
        ]),
        const SizedBox(height: 12),
        Text(g.def ?? '', style: TextStyle(fontSize: 13.5, height: 1.6, color: c.ink2)),
        if (g.docId != null) ...[
          const SizedBox(height: 18),
          AppButton('Ver página completa', full: true, icon: 'chevR',
            onTap: () { Navigator.pop(ctx); onOpenDoc?.call(g.docId!); }),
        ],
      ]),
    ),
  );
}
