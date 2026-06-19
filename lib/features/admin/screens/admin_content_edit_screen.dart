import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/content/content_id.dart';
import '../../../data/models/content_doc.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/content/icon_picker.dart';
import '../../../shared/content/media_uploader.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_field.dart';
import '../../../shared/widgets/icon_tile.dart';

const _sectionTypes = <({String type, String label})>[
  (type: 'rich', label: 'Texto'),
  (type: 'steps', label: 'Passo a passo'),
  (type: 'docs', label: 'Lista / documentos'),
  (type: 'media', label: 'Vídeo / imagem'),
  (type: 'callout', label: 'Destaque'),
  (type: 'faq', label: 'Dúvidas'),
  (type: 'sources', label: 'Fontes oficiais'),
];

String _labelOf(String type) => _sectionTypes.firstWhere((e) => e.type == type, orElse: () => (type: type, label: type)).label;

Map<String, dynamic> _newSection(String type) => switch (type) {
  'rich' => {'type': 'rich', 'heading': 'Novo título', 'body': 'Escreva aqui. Use [[termos]] para links internos.'},
  'steps' => {'type': 'steps', 'heading': 'Como solicitar', 'items': ['Primeiro passo', 'Segundo passo']},
  'docs' => {'type': 'docs', 'heading': 'Documentos necessários', 'items': ['Documento 1']},
  'media' => {'type': 'media', 'mediaType': 'image', 'heading': 'Vídeo ou imagem', 'caption': ''},
  'callout' => {'type': 'callout', 'variant': 'info', 'body': 'Aviso importante.'},
  'faq' => {'type': 'faq', 'heading': 'Dúvidas frequentes', 'items': [{'q': 'Pergunta?', 'a': 'Resposta.'}]},
  'sources' => {'type': 'sources', 'heading': 'Canais oficiais', 'items': [{'label': 'Site oficial', 'url': 'gov.br'}]},
  _ => {'type': 'rich', 'heading': '', 'body': ''},
};

class AdminContentEditScreen extends ConsumerStatefulWidget {
  final ContentDoc? doc;
  const AdminContentEditScreen({super.key, required this.doc});
  @override
  ConsumerState<AdminContentEditScreen> createState() => _AdminContentEditScreenState();
}

class _AdminContentEditScreenState extends ConsumerState<AdminContentEditScreen> {
  late String _title, _tag, _summary, _icon;
  late ContentKind _kind;
  late List<Map<String, dynamic>> _sections;
  bool get _isNew => widget.doc == null;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.doc;
    _title = d?.title ?? '';
    _tag = d?.tag ?? '';
    _summary = d?.summary ?? '';
    _icon = d?.icon ?? 'doc';
    _kind = d?.kind ?? ContentKind.gov;
    _sections = (d?.sections ?? const <ContentSection>[]).map((s) => _deep(s.toMap())).toList();
  }

  Map<String, dynamic> _deep(Map<String, dynamic> m) => {
    for (final e in m.entries)
      e.key: e.value is List
          ? [for (final i in e.value as List) i is Map ? Map<String, dynamic>.from(i) : i]
          : e.value,
  };

  void _mut(VoidCallback fn) => setState(fn);
  void _move(int i, int dir) {
    final j = i + dir;
    if (j < 0 || j >= _sections.length) return;
    _mut(() { final t = _sections[i]; _sections[i] = _sections[j]; _sections[j] = t; });
  }

  Future<void> _publish() async {
    if (_title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe um título.')));
      return;
    }
    if (_sections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adicione ao menos uma seção.')));
      return;
    }
    setState(() => _saving = true);
    final repo = ref.read(universeRepositoryProvider);
    final existingIds = (ref.read(allContentDocsProvider).valueOrNull ?? const <ContentDoc>[]).map((d) => d.id).toSet();
    final id = _isNew ? generateDocId(_kind, _title, existingIds) : widget.doc!.id;
    final doc = ContentDoc(
      id: id, kind: _kind, icon: _icon, title: _title.trim(), tag: _tag.trim(), summary: _summary.trim(),
      updatedAt: DateTime.now(),
      sections: _sections.map((m) => ContentSection.fromMap(Map<String, dynamic>.from(m))).whereType<ContentSection>().toList(),
    );
    await repo.upsertContentDoc(doc);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conteúdo publicado!')));
      Navigator.of(context).pop();
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Excluir página'),
      content: Text('Excluir "$_title"? Esta ação não pode ser desfeita.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Excluir')),
      ],
    ));
    if (ok == true) {
      await ref.read(universeRepositoryProvider).deleteContentDoc(widget.doc!.id);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Página excluída'))); Navigator.of(context).pop(); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(title: _isNew ? 'Nova página' : 'Editar página', subtitle: _isNew ? null : _title, icon: 'edit', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Cabeçalho do doc
          AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (_isNew) ...[
              Text('Tipo', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.ink2)),
              const SizedBox(height: 7),
              Row(children: [
                for (final k in ContentKind.values) Expanded(child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _mut(() => _kind = k),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9), alignment: Alignment.center,
                      decoration: BoxDecoration(color: _kind == k ? c.green800 : c.bg2, borderRadius: BorderRadius.circular(10)),
                      child: Text(k == ContentKind.gov ? 'Governamental' : 'Institucional', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _kind == k ? Colors.white : c.ink2)),
                    ),
                  ),
                )),
              ]),
              const SizedBox(height: 12),
            ],
            AppField(label: 'Título', icon: 'edit', value: _title, onChanged: (v) => _mut(() => _title = v)),
            const SizedBox(height: 11),
            AppField(label: 'Etiqueta (tag)', value: _tag, onChanged: (v) => _mut(() => _tag = v)),
            const SizedBox(height: 11),
            AppField(label: 'Resumo (aparece na lista)', multiline: true, value: _summary, onChanged: (v) => _mut(() => _summary = v)),
            const SizedBox(height: 13),
            Text('Ícone', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.ink2)),
            const SizedBox(height: 9),
            IconPicker(selected: _icon, onSelect: (n) => _mut(() => _icon = n)),
          ])),
          const SizedBox(height: 14),
          // Seções
          for (var i = 0; i < _sections.length; i++) Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SectionEditor(
              key: ValueKey(_sections[i]),
              section: _sections[i],
              first: i == 0, last: i == _sections.length - 1,
              onUp: () => _move(i, -1), onDown: () => _move(i, 1),
              onDelete: () => _mut(() => _sections.removeAt(i)),
              onChanged: () => _mut(() {}),
            ),
          ),
          // Adicionar seção
          _AddSection(onAdd: (type) => _mut(() => _sections.add(_newSection(type)))),
          const SizedBox(height: 18),
          AppButton(_saving ? 'Publicando…' : 'Publicar', full: true, icon: 'check', onTap: _saving ? null : _publish),
          if (!_isNew) ...[
            const SizedBox(height: 10),
            AppButton('Excluir página', full: true, variant: AppButtonVariant.outline, onTap: _delete),
          ],
          const SizedBox(height: 10),
          Center(child: Text('A data de atualização será definida para hoje.', style: TextStyle(fontSize: 11, color: c.ink3))),
        ]),
      ),
    );
  }
}

/// Editor de uma seção (muta o mapa in-place; chama onChanged p/ rebuild).
class _SectionEditor extends StatelessWidget {
  final Map<String, dynamic> section;
  final bool first, last;
  final VoidCallback onUp, onDown, onDelete, onChanged;
  const _SectionEditor({super.key, required this.section, required this.first, required this.last, required this.onUp, required this.onDown, required this.onDelete, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final type = section['type'] as String;
    Widget headerRow = Row(children: [
      Expanded(child: Text(_labelOf(type).toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.3, color: c.ink3))),
      IconButton(onPressed: first ? null : onUp, icon: const Icon(Icons.keyboard_arrow_up), iconSize: 20, color: c.ink3),
      IconButton(onPressed: last ? null : onDown, icon: const Icon(Icons.keyboard_arrow_down), iconSize: 20, color: c.ink3),
      IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline), iconSize: 19, color: c.error),
    ]);

    final children = <Widget>[headerRow];
    if (section.containsKey('heading')) {
      children.add(Padding(padding: const EdgeInsets.only(top: 6), child: AppField(
        hint: 'Título da seção', value: (section['heading'] ?? '') as String,
        onChanged: (v) { section['heading'] = v; onChanged(); })));
    }

    if (type == 'rich' || type == 'callout') {
      children.add(const SizedBox(height: 10));
      children.add(AppField(label: type == 'callout' ? 'Texto do destaque' : 'Texto', multiline: true,
        value: (section['body'] ?? '') as String, onChanged: (v) { section['body'] = v; onChanged(); }));
    }
    if (type == 'callout') {
      children.add(const SizedBox(height: 10));
      children.add(Row(children: [
        for (final v in const [('info', 'Informação'), ('warn', 'Atenção')]) Expanded(child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () { section['variant'] = v.$1; onChanged(); },
            child: Container(padding: const EdgeInsets.symmetric(vertical: 9), alignment: Alignment.center,
              decoration: BoxDecoration(color: section['variant'] == v.$1 ? c.green800 : c.bg2, borderRadius: BorderRadius.circular(10)),
              child: Text(v.$2, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: section['variant'] == v.$1 ? Colors.white : c.ink2))),
          ),
        )),
      ]));
    }
    if (type == 'steps' || type == 'docs') {
      final items = List<String>.from(section['items'] ?? const []);
      children.add(const SizedBox(height: 10));
      children.add(AppField(label: 'Itens (um por linha)', multiline: true, value: items.join('\n'),
        onChanged: (v) { section['items'] = v.split('\n').where((e) => e.trim().isNotEmpty).toList(); onChanged(); }));
    }
    if (type == 'media') {
      children.add(const SizedBox(height: 10));
      children.add(MediaUploader(
        mediaType: (section['mediaType'] ?? 'image') as String,
        imageUrl: section['imageUrl'] as String?, videoUrl: section['videoUrl'] as String?,
        onChange: ({required mediaType, imageUrl, videoUrl}) { section['mediaType'] = mediaType; section['imageUrl'] = imageUrl; section['videoUrl'] = videoUrl; onChanged(); }));
      children.add(const SizedBox(height: 10));
      children.add(AppField(hint: 'Legenda (opcional)', value: (section['caption'] ?? '') as String,
        onChanged: (v) { section['caption'] = v; onChanged(); }));
    }
    if (type == 'faq') {
      final items = (section['items'] as List).cast<Map>();
      for (var j = 0; j < items.length; j++) {
        children.add(const SizedBox(height: 10));
        children.add(AppField(hint: 'Pergunta', value: (items[j]['q'] ?? '') as String, onChanged: (v) { items[j]['q'] = v; onChanged(); }));
        children.add(const SizedBox(height: 6));
        children.add(AppField(hint: 'Resposta', multiline: true, value: (items[j]['a'] ?? '') as String, onChanged: (v) { items[j]['a'] = v; onChanged(); }));
      }
      children.add(Align(alignment: Alignment.centerLeft, child: TextButton.icon(
        onPressed: () { items.add({'q': 'Pergunta?', 'a': 'Resposta.'}); section['items'] = items; onChanged(); },
        icon: Icon(appIcon('plus'), size: 16, color: c.green700), label: Text('Adicionar pergunta', style: TextStyle(color: c.green700, fontWeight: FontWeight.w700, fontSize: 12.5)))));
    }
    if (type == 'sources') {
      final items = (section['items'] as List).cast<Map>();
      for (var j = 0; j < items.length; j++) {
        children.add(const SizedBox(height: 10));
        children.add(AppField(hint: 'Nome', value: (items[j]['label'] ?? '') as String, onChanged: (v) { items[j]['label'] = v; onChanged(); }));
        children.add(const SizedBox(height: 6));
        children.add(AppField(hint: 'endereco.gov.br', value: (items[j]['url'] ?? '') as String, onChanged: (v) { items[j]['url'] = v; onChanged(); }));
      }
      children.add(Align(alignment: Alignment.centerLeft, child: TextButton.icon(
        onPressed: () { items.add({'label': 'Site oficial', 'url': 'gov.br'}); section['items'] = items; onChanged(); },
        icon: Icon(appIcon('plus'), size: 16, color: c.green700), label: Text('Adicionar fonte', style: TextStyle(color: c.green700, fontWeight: FontWeight.w700, fontSize: 12.5)))));
    }

    return AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children));
  }
}

class _AddSection extends StatefulWidget {
  final ValueChanged<String> onAdd;
  const _AddSection({required this.onAdd});
  @override
  State<_AddSection> createState() => _AddSectionState();
}

class _AddSectionState extends State<_AddSection> {
  bool _open = false;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    if (!_open) {
      return AppButton('Adicionar seção', full: true, variant: AppButtonVariant.outline, icon: 'plus', onTap: () => setState(() => _open = true));
    }
    return AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('TIPO DE SEÇÃO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: c.ink3)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final s in _sectionTypes)
          GestureDetector(
            onTap: () { widget.onAdd(s.type); setState(() => _open = false); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: c.bg2, borderRadius: BorderRadius.circular(11)),
              child: Text(s.label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.ink)),
            ),
          ),
      ]),
      const SizedBox(height: 8),
      TextButton(onPressed: () => setState(() => _open = false), child: Text('Cancelar', style: TextStyle(color: c.ink3))),
    ]));
  }
}
