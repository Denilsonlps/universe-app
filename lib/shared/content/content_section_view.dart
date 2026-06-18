import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/content_doc.dart';
import '../widgets/accordion.dart';
import '../widgets/app_card.dart';
import '../widgets/icon_tile.dart';
import '../widgets/section_title.dart';
import 'media_view.dart';
import 'wiki_text.dart';

class ContentSectionView extends StatelessWidget {
  final ContentSection section;
  final void Function(String docId) onOpenDoc;
  final void Function(String termKey) onOpenTerm;
  const ContentSectionView({super.key, required this.section, required this.onOpenDoc, required this.onOpenTerm});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final s = section;
    Widget heading(String? h) => h == null
        ? const SizedBox.shrink()
        : Padding(padding: const EdgeInsets.only(bottom: 11), child: SectionTitle(h));

    switch (s) {
      case RichSection():
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          heading(s.heading),
          WikiParagraphs(s.body, onOpenDoc: onOpenDoc, onOpenTerm: onOpenTerm),
        ]);
      case StepsSection():
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          heading(s.heading),
          for (var i = 0; i < s.items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 27,
                  height: 27,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: c.green800, shape: BoxShape.circle),
                  child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: WikiText(s.items[i], onOpenDoc: onOpenDoc, onOpenTerm: onOpenTerm, style: TextStyle(fontSize: 13.5, height: 1.5, color: c.ink)),
                ),
              ]),
            ),
        ]);
      case DocsSection():
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          heading(s.heading),
          AppCard(
            child: Column(children: [
              for (final it in s.items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(appIcon('checkCircle'), size: 18, color: c.green500),
                    const SizedBox(width: 11),
                    Expanded(
                      child: WikiText(it, onOpenDoc: onOpenDoc, onOpenTerm: onOpenTerm, style: TextStyle(fontSize: 13.5, height: 1.45, color: c.ink)),
                    ),
                  ]),
                ),
            ]),
          ),
        ]);
      case MediaSection():
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          heading(s.heading),
          MediaView(mediaType: s.mediaType, imageUrl: s.imageUrl, videoUrl: s.videoUrl, caption: s.caption),
        ]);
      case CalloutSection():
        final warn = s.variant == 'warn';
        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: warn ? const Color(0x1FF2B01E) : c.green050,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: warn ? const Color(0x4DF2B01E) : c.green100),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(appIcon(warn ? 'bell' : 'shield'), size: 20, color: warn ? const Color(0xFFC98A0E) : c.green600),
            const SizedBox(width: 12),
            Expanded(
              child: WikiText(s.body, onOpenDoc: onOpenDoc, onOpenTerm: onOpenTerm, style: TextStyle(fontSize: 12.5, height: 1.5, color: c.ink2, fontWeight: FontWeight.w500)),
            ),
          ]),
        );
      case FaqSection():
        return _FaqList(section: s, onOpenDoc: onOpenDoc, onOpenTerm: onOpenTerm);
      case SourcesSection():
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          heading(s.heading),
          for (final src in s.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: AppCard(
                onTap: () {
                  final uri = Uri.tryParse(src.url.startsWith('http') ? src.url : 'https://${src.url}');
                  if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(children: [
                  Icon(appIcon('globe'), size: 19, color: c.green700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(src.label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink)),
                      Text(src.url, style: TextStyle(fontSize: 11.5, color: c.green700)),
                    ]),
                  ),
                  Icon(appIcon('chevR'), size: 16, color: c.ink3),
                ]),
              ),
            ),
        ]);
    }
  }
}

class _FaqList extends StatefulWidget {
  final FaqSection section;
  final void Function(String docId) onOpenDoc;
  final void Function(String termKey) onOpenTerm;
  const _FaqList({required this.section, required this.onOpenDoc, required this.onOpenTerm});

  @override
  State<_FaqList> createState() => _FaqListState();
}

class _FaqListState extends State<_FaqList> {
  int _open = -1;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (widget.section.heading != null)
        Padding(padding: const EdgeInsets.only(bottom: 11), child: SectionTitle(widget.section.heading!)),
      for (var i = 0; i < widget.section.items.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Accordion(
            question: widget.section.items[i].q,
            answer: widget.section.items[i].a,
            open: _open == i,
            onToggle: () => setState(() => _open = _open == i ? -1 : i),
          ),
        ),
    ]);
  }
}
