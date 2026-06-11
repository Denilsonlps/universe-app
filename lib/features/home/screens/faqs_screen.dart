import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../data/repositories/mock_repository.dart';
import '../../../data/models/faq_model.dart';

class FAQsScreen extends StatefulWidget {
  const FAQsScreen({super.key});

  @override
  State<FAQsScreen> createState() => _FAQsScreenState();
}

class _FAQsScreenState extends State<FAQsScreen> {
  String _selectedCat = 'Todas';
  String _query = '';
  int _openIdx = 0;
  final _searchController = TextEditingController();

  static const _cats = ['Todas', 'Campus', 'Enem', 'Gerais'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = MockRepository.faqs;
    final filtered = all.where((f) {
      final matchesCat = _selectedCat == 'Todas' || f.category == _selectedCat;
      final matchesQuery = _query.isEmpty || f.question.toLowerCase().contains(_query.toLowerCase());
      return matchesCat && matchesQuery;
    }).toList();

    return ColoredBox(
      color: AppColors.bg,
      child: Column(
        children: [
          // Header
          Container(
            color: AppColors.bg,
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top,
              16,
              12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                const Text(
                  'Dúvidas',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 12),
                _SearchField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                ),
              ],
            ),
          ),
          // Category chips
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: _cats.length,
              separatorBuilder: (_, _) => const SizedBox(width: 9),
              itemBuilder: (_, i) => AppChip(
                label: _cats[i],
                active: _selectedCat == _cats[i],
                onTap: () => setState(() => _selectedCat = _cats[i]),
              ),
            ),
          ),
          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              children: [
                ...List.generate(filtered.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AccordionItem(
                      faq: filtered[i],
                      isOpen: _openIdx == i,
                      onToggle: () => setState(() => _openIdx = _openIdx == i ? -1 : i),
                    ),
                  );
                }),
                if (filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: _EmptyState(),
                  ),
                const SizedBox(height: 16),
                _ContactCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccordionItem extends StatelessWidget {
  final FAQModel faq;
  final bool isOpen;
  final VoidCallback onToggle;

  const _AccordionItem({required this.faq, required this.isOpen, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0D281C).withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1)),
          BoxShadow(color: const Color(0xFF0D281C).withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              color: AppColors.card,
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      faq.question,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.green600),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                faq.answer,
                style: const TextStyle(fontSize: 13, height: 1.55, color: AppColors.ink2),
              ),
            ),
            crossFadeState: isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(color: AppColors.line, blurRadius: 0, spreadRadius: 1.5),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 19, color: AppColors.ink3),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 15, color: AppColors.ink, fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                hintText: 'Pesquisar dúvidas…',
                hintStyle: TextStyle(fontSize: 15, color: AppColors.ink3),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.help_outline_rounded, size: 48, color: AppColors.ink3),
        SizedBox(height: 12),
        Text('Nenhuma dúvida encontrada', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink)),
        SizedBox(height: 4),
        Text('Não achamos resultados. Encaminhe sua pergunta abaixo.', style: TextStyle(fontSize: 13, color: AppColors.ink3), textAlign: TextAlign.center),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEEF6F0), Colors.white],
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0D281C).withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1)),
          BoxShadow(color: const Color(0xFF0D281C).withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.green100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.send_rounded, size: 20, color: AppColors.green700),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Não achou sua dúvida?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink)),
                  Text('Encaminhe direto para o campus', style: TextStyle(fontSize: 12, color: AppColors.ink2)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Enviar mensagem'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green800,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
