import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/contest.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_field.dart';

class ConcursoFormScreen extends ConsumerStatefulWidget {
  final Contest? contest;
  const ConcursoFormScreen({super.key, this.contest});
  @override
  ConsumerState<ConcursoFormScreen> createState() => _ConcursoFormScreenState();
}

class _ConcursoFormScreenState extends ConsumerState<ConcursoFormScreen> {
  late final _ct = widget.contest;
  late String _role = _ct?.role ?? '';
  late String _org = _ct?.org ?? '';
  late String _vagas = _ct?.vagas ?? '';
  late String _salary = _ct?.salary ?? '';
  late String _level = _ct?.level ?? '';
  late String _about = _ct?.about ?? '';
  late String _link = _ct?.link ?? '';
  late DateTime _deadline = _ct?.deadline ?? DateTime.now().add(const Duration(days: 30));
  bool _saving = false;
  bool _showErrors = false;

  bool get _valid => _role.trim().isNotEmpty && _org.trim().isNotEmpty;

  Future<void> _save() async {
    setState(() => _showErrors = true);
    if (!_valid) return;
    setState(() => _saving = true);
    final repo = ref.read(universeRepositoryProvider);
    final id = _ct?.id ?? repo.newId('contests');
    final ct = Contest(id: id, role: _role.trim(), org: _org.trim(), vagas: _vagas.trim(),
      salary: _salary.trim(), level: _level.trim(), about: _about.trim(),
      link: _link.trim().isEmpty ? null : _link.trim(), deadline: _deadline);
    try {
      await repo.upsertContest(ct);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Concurso salvo!')));
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
    final prazo = '${_deadline.day.toString().padLeft(2, '0')}/${_deadline.month.toString().padLeft(2, '0')}/${_deadline.year}';
    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: PageHeader(title: _ct == null ? 'Novo concurso' : 'Editar concurso', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppField(label: 'Cargo', icon: 'doc', value: _role, error: err(_role), onChanged: (v) => setState(() => _role = v)),
          const SizedBox(height: 12),
          AppField(label: 'Órgão', icon: 'institution', value: _org, error: err(_org), onChanged: (v) => setState(() => _org = v)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: AppField(label: 'Vagas', value: _vagas, onChanged: (v) => setState(() => _vagas = v))),
            const SizedBox(width: 10),
            Expanded(child: AppField(label: 'Salário', icon: 'card', value: _salary, onChanged: (v) => setState(() => _salary = v))),
          ]),
          const SizedBox(height: 12),
          AppField(label: 'Escolaridade', value: _level, onChanged: (v) => setState(() => _level = v)),
          const SizedBox(height: 12),
          AppField(label: 'Sobre', value: _about, onChanged: (v) => setState(() => _about = v)),
          const SizedBox(height: 12),
          AppField(label: 'Link (opcional)', icon: 'globe', value: _link, onChanged: (v) => setState(() => _link = v)),
          const SizedBox(height: 12),
          Text('Prazo de inscrição', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.ink2)),
          const SizedBox(height: 7),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(context: context, initialDate: _deadline, firstDate: DateTime(2020), lastDate: DateTime(2100));
              if (picked != null) setState(() => _deadline = picked);
            },
            child: Container(
              height: 50, padding: const EdgeInsets.symmetric(horizontal: 14), alignment: Alignment.centerLeft,
              decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(13), border: Border.all(color: c.line, width: 1.5)),
              child: Row(children: [Icon(Icons.event, size: 19, color: c.ink3), const SizedBox(width: 10), Text(prazo, style: TextStyle(fontSize: 15, color: c.ink))]),
            ),
          ),
          const SizedBox(height: 20),
          AppButton(_saving ? 'Salvando…' : 'Salvar concurso', full: true, icon: 'check', onTap: _saving ? null : _save),
          const SizedBox(height: 10),
          AppButton('Cancelar', full: true, variant: AppButtonVariant.ghost, onTap: () => context.pop()),
        ]),
      ),
    );
  }
}
