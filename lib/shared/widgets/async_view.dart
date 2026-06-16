import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import 'app_button.dart';
import 'empty_state.dart';

/// Renderiza um `AsyncValue<List<T>>` com estados padrão.
class AsyncListView<T> extends StatelessWidget {
  final AsyncValue<List<T>> value;
  final Widget Function(List<T> items) data;
  final String emptyTitle;
  final String? emptyBody;
  final VoidCallback onRetry;
  const AsyncListView({super.key, required this.value, required this.data, required this.onRetry, this.emptyTitle = 'Nada por aqui', this.emptyBody});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return value.when(
      loading: () => const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(children: [
          Text('Não foi possível carregar.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.ink)),
          const SizedBox(height: 6),
          Text('Verifique sua conexão e tente novamente.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: c.ink3)),
          const SizedBox(height: 16),
          AppButton('Tentar novamente', variant: AppButtonVariant.outline, onTap: onRetry),
        ]),
      ),
      data: (items) => items.isEmpty ? EmptyState(icon: 'search', title: emptyTitle, body: emptyBody) : data(items),
    );
  }
}
