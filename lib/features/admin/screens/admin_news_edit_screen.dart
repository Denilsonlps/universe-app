import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/news.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/content/image_picker_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_field.dart';
import '../../../shared/widgets/app_toggle.dart';
import '../../../shared/widgets/icon_tile.dart';
import '../../../shared/widgets/section_title.dart';

const _categorias = ['Campus', 'SiSU', 'Enem', 'Geral'];

class AdminNewsEditScreen extends ConsumerStatefulWidget {
  final News? news;
  final String? fromSuggestionId; // se veio de uma sugestão, removê-la ao salvar
  const AdminNewsEditScreen({super.key, required this.news, this.fromSuggestionId});
  @override
  ConsumerState<AdminNewsEditScreen> createState() => _AdminNewsEditScreenState();
}

class _AdminNewsEditScreenState extends ConsumerState<AdminNewsEditScreen> {
  late final _n = widget.news;
  late String _title = _n?.title ?? '';
  late String _category = _n?.category ?? 'Campus';
  late String _source = _n?.source ?? 'IFSP Pirituba';
  late String _readTime = _n?.readTime ?? '2 min';
  late String _summary = _n?.summary ?? '';
  late String _body = _n?.body ?? '';
  late String _sourceUrl = _n?.sourceUrl ?? '';
  late String? _imageUrl = _n?.imageUrl;
  late final List<({String label, String value})> _facts = List.of(_n?.facts ?? const []);
  late bool _pinned = _n?.pinned ?? false;
  // Vindo de uma sugestão, já assume publicar; senão usa o valor da notícia (true em nova).
  late bool _published = widget.fromSuggestionId != null ? true : (_n?.published ?? true);
  bool _saving = false;
  bool get _isNew => _n == null;
  bool get _valid => _title.trim().isNotEmpty && _body.trim().length > 10;

  Future<void> _save() async {
    if (!_valid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe título e corpo da notícia.')));
      return;
    }
    setState(() => _saving = true);
    final repo = ref.read(universeRepositoryProvider);
    final id = _n?.id ?? repo.newId('news');
    final news = News(
      id: id, category: _category.trim().isEmpty ? 'Geral' : _category.trim(),
      source: _source.trim(), readTime: _readTime.trim(), title: _title.trim(),
      summary: _summary.trim(), body: _body.trim(), date: _n?.date ?? DateTime.now(),
      facts: _facts, sourceUrl: _sourceUrl.trim().isEmpty ? null : _sourceUrl.trim(),
      imageUrl: _imageUrl, published: _published, pinned: _pinned,
    );
    try {
      await repo.upsertNews(news);
      if (widget.fromSuggestionId != null) {
        await repo.deleteNoticiaSugerida(widget.fromSuggestionId!);
      }
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notícia salva!'))); context.pop(); }
    } catch (_) {
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao salvar. Tente novamente.'))); setState(() => _saving = false); }
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Excluir notícia'),
      content: Text('Excluir "$_title"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Excluir')),
      ],
    ));
    if (ok == true) {
      try {
        await ref.read(universeRepositoryProvider).deleteNews(_n!.id);
        if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notícia excluída'))); context.pop(); }
      } catch (_) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao excluir.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(title: _isNew ? 'Nova notícia' : 'Editar notícia', subtitle: _isNew ? null : _title, icon: 'edit', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppField(label: 'Título', icon: 'edit', value: _title, onChanged: (v) => setState(() => _title = v)),
          const SizedBox(height: 12),
          Text('Categoria', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.ink2)),
          const SizedBox(height: 7),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final cat in _categorias)
              GestureDetector(
                onTap: () => setState(() => _category = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                  decoration: BoxDecoration(color: _category == cat ? c.green800 : c.bg2, borderRadius: BorderRadius.circular(999)),
                  child: Text(cat, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _category == cat ? Colors.white : c.ink2)),
                ),
              ),
          ]),
          const SizedBox(height: 8),
          AppField(label: 'Categoria (livre, opcional)', value: _category, onChanged: (v) => setState(() => _category = v)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: AppField(label: 'Fonte', icon: 'institution', value: _source, onChanged: (v) => setState(() => _source = v))),
            const SizedBox(width: 10),
            Expanded(child: AppField(label: 'Tempo de leitura', icon: 'clock', value: _readTime, onChanged: (v) => setState(() => _readTime = v))),
          ]),
          const SizedBox(height: 12),
          AppField(label: 'Resumo (aparece no card)', multiline: true, value: _summary, onChanged: (v) => setState(() => _summary = v)),
          const SizedBox(height: 12),
          AppField(label: 'Texto completo (use [[termos]] para links)', multiline: true, value: _body, onChanged: (v) => setState(() => _body = v)),
          const SizedBox(height: 18),
          const SectionTitle('Fatos rápidos'),
          for (var i = 0; i < _facts.length; i++) Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(child: AppField(hint: 'Rótulo', value: _facts[i].label, onChanged: (v) => setState(() => _facts[i] = (label: v, value: _facts[i].value)))),
              const SizedBox(width: 8),
              Expanded(child: AppField(hint: 'Valor', value: _facts[i].value, onChanged: (v) => setState(() => _facts[i] = (label: _facts[i].label, value: v)))),
              IconButton(onPressed: () => setState(() => _facts.removeAt(i)), icon: Icon(Icons.delete_outline, size: 19, color: c.error)),
            ]),
          ),
          Align(alignment: Alignment.centerLeft, child: TextButton.icon(
            onPressed: () => setState(() => _facts.add((label: '', value: ''))),
            icon: Icon(appIcon('plus'), size: 16, color: c.green700),
            label: Text('Adicionar fato', style: TextStyle(color: c.green700, fontWeight: FontWeight.w700, fontSize: 12.5)),
          )),
          const SizedBox(height: 14),
          const SectionTitle('Imagem (opcional)'),
          ImagePickerField(imageUrl: _imageUrl, onChanged: (url) => setState(() => _imageUrl = url)),
          const SizedBox(height: 14),
          AppField(label: 'Link da fonte oficial', icon: 'globe', value: _sourceUrl, onChanged: (v) => setState(() => _sourceUrl = v)),
          const SizedBox(height: 14),
          AppCard(child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Destaque na Home', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.ink)),
              Text('Marca a notícia como prioritária', style: TextStyle(fontSize: 11.5, color: c.ink3)),
            ])),
            AppToggle(on: _pinned, onChanged: (v) => setState(() => _pinned = v)),
          ])),
          const SizedBox(height: 10),
          AppCard(child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Publicar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.ink)),
              Text(_published ? 'Visível para os alunos' : 'Salva como rascunho', style: TextStyle(fontSize: 11.5, color: c.ink3)),
            ])),
            AppToggle(on: _published, onChanged: (v) => setState(() => _published = v)),
          ])),
          const SizedBox(height: 18),
          AppButton(_saving ? 'Salvando…' : 'Salvar notícia', full: true, icon: 'check', onTap: _saving ? null : _save),
          if (!_isNew) ...[
            const SizedBox(height: 10),
            AppButton('Excluir notícia', full: true, variant: AppButtonVariant.outline, onTap: _delete),
          ],
        ]),
      ),
    );
  }
}
