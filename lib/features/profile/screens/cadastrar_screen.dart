import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/courses.dart';
import '../../../data/profile/student_profile.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_field.dart';
import '../../../shared/widgets/user_avatar.dart';

class CadastrarScreen extends ConsumerStatefulWidget {
  const CadastrarScreen({super.key});
  @override
  ConsumerState<CadastrarScreen> createState() => _CadastrarScreenState();
}

class _CadastrarScreenState extends ConsumerState<CadastrarScreen> {
  String? _course;
  String _enroll = '';
  bool _loading = false;
  bool _init = false;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final user = ref.watch(authStateProvider).valueOrNull;
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    // pré-preenche uma vez quando o perfil chega
    if (!_init && profile != null) {
      _course = profile.course;
      _enroll = profile.enrollment ?? '';
      _init = true;
    }

    Future<void> save() async {
      final uid = user?.id;
      if (uid == null) return;
      setState(() => _loading = true);
      try {
        await ref.read(profileRepositoryProvider).save(StudentProfile(uid: uid, course: _course, enrollment: _enroll.trim().isEmpty ? null : _enroll.trim()));
        ref.invalidate(currentProfileProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informações salvas!')));
          context.pop();
        }
      } catch (_) {
        if (context.mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao salvar. Tente novamente.')));
        }
      }
    }

    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: PageHeader(title: 'Editar perfil', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Column(children: [
            UserAvatar(user?.name ?? 'Estudante', size: 88),
            const SizedBox(height: 10),
            Text(user?.name ?? '', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink)),
            if (user?.email != null) Text(user!.email, style: TextStyle(fontSize: 12.5, color: c.ink3)),
          ])),
          const SizedBox(height: 22),
          Text('Curso', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.ink2)),
          const SizedBox(height: 7),
          DropdownButtonFormField<String>(
            initialValue: _course,
            isExpanded: true,
            decoration: InputDecoration(filled: true, fillColor: c.card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(13))),
            items: [for (final n in campusCourses) DropdownMenuItem(value: n, child: Text(n, overflow: TextOverflow.ellipsis))],
            onChanged: (v) => setState(() => _course = v),
          ),
          const SizedBox(height: 14),
          AppField(label: 'Nº de matrícula', icon: 'card', value: _enroll, onChanged: (v) => setState(() => _enroll = v)),
          const SizedBox(height: 24),
          AppButton(_loading ? 'Salvando…' : 'Salvar alterações', full: true, icon: 'check', onTap: _loading ? null : save),
          const SizedBox(height: 10),
          AppButton('Cancelar', full: true, variant: AppButtonVariant.ghost, onTap: () => context.pop()),
        ]),
      ),
    );
  }
}
