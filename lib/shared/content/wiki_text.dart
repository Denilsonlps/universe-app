import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/content/glossary.dart';

/// Token de wiki-texto: trecho de texto plano OU um link (linkKey != null).
class WikiToken {
  final String text;
  final String? linkKey;
  const WikiToken(this.text, [this.linkKey]);
}

final _wikiRe = RegExp(r'\[\[([^\]]+)\]\]');

List<WikiToken> parseWikiTokens(String text) {
  final out = <WikiToken>[];
  var last = 0;
  for (final m in _wikiRe.allMatches(text)) {
    if (m.start > last) out.add(WikiToken(text.substring(last, m.start)));
    final inner = m.group(1)!;
    final parts = inner.split('|');
    final key = parts.first;
    final disp = parts.length > 1 ? parts[1] : parts.first;
    out.add(WikiToken(disp, key));
    last = m.end;
  }
  if (last < text.length) out.add(WikiToken(text.substring(last)));
  return out;
}

/// Renderiza texto com `[[chave]]`/`[[chave|exibição]]` como links do glossário.
class WikiText extends StatelessWidget {
  final String text;
  final void Function(String docId) onOpenDoc;
  final void Function(String termKey) onOpenTerm;
  final TextStyle? style;
  const WikiText(this.text, {super.key, required this.onOpenDoc, required this.onOpenTerm, this.style});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final base = style ?? TextStyle(fontSize: 13.5, height: 1.62, color: c.ink2);
    final linkStyle = base.copyWith(color: c.green700, fontWeight: FontWeight.w700, decoration: TextDecoration.underline, decorationColor: c.green100);
    return Text.rich(TextSpan(children: [
      for (final tk in parseWikiTokens(text))
        if (tk.linkKey != null && glossary.containsKey(tk.linkKey))
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: () {
                final g = glossary[tk.linkKey]!;
                if (g.def != null) { onOpenTerm(tk.linkKey!); }
                else if (g.docId != null) { onOpenDoc(g.docId!); }
              },
              child: Text(tk.text, style: linkStyle),
            ),
          )
        else
          TextSpan(text: tk.text, style: base),
    ]));
  }
}

/// Parágrafos separados por \n\n, cada um com wikilinks.
class WikiParagraphs extends StatelessWidget {
  final String text;
  final void Function(String docId) onOpenDoc;
  final void Function(String termKey) onOpenTerm;
  const WikiParagraphs(this.text, {super.key, required this.onOpenDoc, required this.onOpenTerm});
  @override
  Widget build(BuildContext context) {
    final paras = text.split('\n\n');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (var i = 0; i < paras.length; i++)
        Padding(padding: EdgeInsets.only(top: i == 0 ? 0 : 11), child: WikiText(paras[i], onOpenDoc: onOpenDoc, onOpenTerm: onOpenTerm)),
    ]);
  }
}
