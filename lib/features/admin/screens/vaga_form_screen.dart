import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/internship.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/content/image_picker_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_field.dart';
import '../../../shared/widgets/app_toggle.dart';
import '../../../shared/widgets/section_title.dart';

class VagaFormScreen extends ConsumerStatefulWidget {
  final Internship? vaga; // null = nova
  final String? fromSuggestionId; // se veio de uma sugestão, removê-la ao salvar
  const VagaFormScreen({super.key, this.vaga, this.fromSuggestionId});
  @override
  ConsumerState<VagaFormScreen> createState() => _VagaFormScreenState();
}

class _VagaFormScreenState extends ConsumerState<VagaFormScreen> {
  late final _v = widget.vaga;
  late String _role = _v?.role ?? '';
  late String _company = _v?.companyName ?? '';
  late String _area = _v?.area ?? '';
  late String _jobDesc = _v?.jobDescription ?? '';
  late String _companyDesc = _v?.companyDescription ?? '';
  late String _grant = _v?.grant ?? '';
  late String _duration = _v?.duration ?? '';
  late String _link = _v?.link ?? '';
  late String _tag = _v?.tag ?? '';
  late String? _imageUrl = _v?.imageUrl;
  late String _course = _v?.course ?? 'ADS';
  late String _mode = _v?.mode ?? 'Presencial';
  late bool _open = _v?.open ?? true;
  late List<String> _reqs = List.of(_v?.requirements ?? const []);
  late List<String> _nice = List.of(_v?.niceToHave ?? const []);
  late List<String> _benefits = List.of(_v?.benefits ?? const []);
  bool _saving = false;
  bool _showErrors = false;

  static const _courseOptions = ['ADS', 'Gestão Pública', 'Eng. de Produção', 'Redes', 'Administração', 'Logística'];
  static const _modeOptions = ['Presencial', 'Híbrido', 'Remoto'];

  bool get _valid => _role.trim().isNotEmpty && _company.trim().isNotEmpty && _area.trim().isNotEmpty && _jobDesc.trim().isNotEmpty && _grant.trim().isNotEmpty;

  Future<void> _save() async {
    setState(() => _showErrors = true);
    if (!_valid) return;
    setState(() => _saving = true);
    final repo = ref.read(universeRepositoryProvider);
    final id = _v?.id ?? repo.newId('internships');
    final closedAt = _open ? null : (_v?.closedAt ?? DateTime.now());
    final vaga = Internship(
      id: id, role: _role.trim(), companyName: _company.trim(), area: _area.trim(),
      duration: _duration.trim(), jobDescription: _jobDesc.trim(),
      requirements: _reqs, niceToHave: _nice, companyDescription: _companyDesc.trim(),
      benefits: _benefits, grant: _grant.trim(), course: _course, mode: _mode,
      link: _link.trim().isEmpty ? null : _link.trim(),
      tag: _tag.trim().isEmpty ? null : _tag.trim(), imageUrl: _imageUrl, open: _open, closedAt: closedAt,
    );
    try {
      await repo.upsertInternship(vaga);
      if (widget.fromSuggestionId != null) {
        await repo.deleteVagaSugerida(widget.fromSuggestionId!);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vaga salva!')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    String? err(String v) => (_showErrors && v.trim().isEmpty) ? 'Obrigatório' : null;
    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: PageHeader(title: _v == null ? 'Nova vaga' : 'Editar vaga', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppField(label: 'Cargo', icon: 'briefcase', value: _role, error: err(_role), onChanged: (v) => setState(() => _role = v)),
          const SizedBox(height: 12),
          AppField(label: 'Empresa', icon: 'institution', value: _company, error: err(_company), onChanged: (v) => setState(() => _company = v)),
          const SizedBox(height: 12),
          AppField(label: 'Área de atuação', icon: 'doc', value: _area, error: err(_area), onChanged: (v) => setState(() => _area = v)),
          const SizedBox(height: 12),
          AppField(label: 'Descrição da vaga', value: _jobDesc, error: err(_jobDesc), onChanged: (v) => setState(() => _jobDesc = v)),
          const SizedBox(height: 12),
          AppField(label: 'Descrição da empresa', value: _companyDesc, onChanged: (v) => setState(() => _companyDesc = v)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: AppField(label: 'Bolsa', icon: 'card', value: _grant, error: err(_grant), onChanged: (v) => setState(() => _grant = v))),
            const SizedBox(width: 10),
            Expanded(child: AppField(label: 'Duração', icon: 'clock', value: _duration, onChanged: (v) => setState(() => _duration = v))),
          ]),
          const SizedBox(height: 12),
          _Dropdown(label: 'Curso', value: _course, options: _courseOptions, onChanged: (v) => setState(() => _course = v)),
          const SizedBox(height: 12),
          _Dropdown(label: 'Modalidade', value: _mode, options: _modeOptions, onChanged: (v) => setState(() => _mode = v)),
          const SizedBox(height: 12),
          AppField(label: 'Tag (opcional, ex.: Novo)', value: _tag, onChanged: (v) => setState(() => _tag = v)),
          const SizedBox(height: 12),
          AppField(label: 'Link (opcional)', icon: 'globe', value: _link, onChanged: (v) => setState(() => _link = v)),
          const SizedBox(height: 18),
          const SectionTitle('Imagem (opcional)'),
          ImagePickerField(imageUrl: _imageUrl, onChanged: (url) => setState(() => _imageUrl = url)),
          const SizedBox(height: 18),
          _ListEditor(title: 'Pré-requisitos', items: _reqs, onChanged: (l) => setState(() => _reqs = l)),
          _ListEditor(title: 'Diferenciais', items: _nice, onChanged: (l) => setState(() => _nice = l)),
          _ListEditor(title: 'Benefícios', items: _benefits, onChanged: (l) => setState(() => _benefits = l)),
          const SizedBox(height: 4),
          Row(children: [
            Expanded(child: Text('Vaga aberta', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: c.ink))),
            AppToggle(on: _open, onChanged: (v) => setState(() => _open = v)),
          ]),
          const SizedBox(height: 20),
          AppButton(_saving ? 'Salvando…' : 'Salvar vaga', full: true, icon: 'check', onTap: _saving ? null : _save),
          const SizedBox(height: 10),
          AppButton('Cancelar', full: true, variant: AppButtonVariant.ghost, onTap: () => context.pop()),
        ]),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String label, value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  const _Dropdown({required this.label, required this.value, required this.options, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(left: 3, bottom: 7), child: Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.ink2))),
      DropdownButtonFormField<String>(
        initialValue: options.contains(value) ? value : options.first,
        isExpanded: true,
        decoration: InputDecoration(filled: true, fillColor: c.card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(13))),
        items: [for (final o in options) DropdownMenuItem(value: o, child: Text(o))],
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
    ]);
  }
}

class _ListEditor extends StatefulWidget {
  final String title;
  final List<String> items;
  final ValueChanged<List<String>> onChanged;
  const _ListEditor({required this.title, required this.items, required this.onChanged});
  @override
  State<_ListEditor> createState() => _ListEditorState();
}

class _ListEditorState extends State<_ListEditor> {
  String _draft = '';
  final _ctrl = TextEditingController();
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionTitle(widget.title),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final item in widget.items)
            Chip(
              label: Text(item, style: const TextStyle(fontSize: 12)),
              onDeleted: () => widget.onChanged(List.of(widget.items)..remove(item)),
              backgroundColor: c.green050,
            ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(
            controller: _ctrl,
            decoration: InputDecoration(isDense: true, hintText: 'Adicionar item…', border: OutlineInputBorder(borderRadius: BorderRadius.circular(11))),
            onChanged: (v) => _draft = v,
            onSubmitted: (_) => _add(),
          )),
          const SizedBox(width: 8),
          IconButton(onPressed: _add, icon: Icon(Icons.add_circle, color: c.green600)),
        ]),
      ]),
    );
  }
  void _add() {
    final t = _draft.trim();
    if (t.isEmpty) return;
    widget.onChanged(List.of(widget.items)..add(t));
    _ctrl.clear();
    _draft = '';
  }
}
