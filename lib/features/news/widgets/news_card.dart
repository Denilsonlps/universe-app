import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/news.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/icon_tile.dart';

String _fmtDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

class NewsCard extends StatelessWidget {
  final News news;
  final VoidCallback onTap;
  final bool compact;
  const NewsCard({super.key, required this.news, required this.onTap, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.green050, borderRadius: BorderRadius.circular(999)),
      child: Text(news.category, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c.green700)),
    );

    if (compact) {
      return SizedBox(
        width: 250,
        child: AppCard(
          onTap: onTap,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              chip,
              const Spacer(),
              if (news.pinned) Icon(appIcon('star'), size: 14, color: const Color(0xFFF2B01E)),
            ]),
            const SizedBox(height: 9),
            Text(news.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, height: 1.3, color: c.ink)),
            const SizedBox(height: 9),
            Text('${news.source} · ${_fmtDate(news.date)}', style: TextStyle(fontSize: 11, color: c.ink3, fontWeight: FontWeight.w600)),
          ]),
        ),
      );
    }

    return AppCard(
      onTap: onTap,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        IconTile(news.category == 'Campus' ? 'institution' : 'cap', size: 56, iconSize: 26),
        const SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [chip, if (news.pinned) ...[const SizedBox(width: 7), Icon(appIcon('star'), size: 13, color: const Color(0xFFF2B01E))]]),
          const SizedBox(height: 6),
          Text(news.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.3, color: c.ink)),
          const SizedBox(height: 6),
          Text('${news.source} · ${_fmtDate(news.date)} · ${news.readTime}', style: TextStyle(fontSize: 11, color: c.ink3, fontWeight: FontWeight.w600)),
        ])),
      ]),
    );
  }
}
