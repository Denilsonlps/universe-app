import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/green_hero_header.dart';
import '../../../data/repositories/mock_repository.dart';

class CampusDetailScreen extends StatelessWidget {
  final String detailKey;
  const CampusDetailScreen({super.key, required this.detailKey});

  static const _titles = {
    'about': 'Sobre o Campus',
    'address': 'Endereço e Contato',
    'hours': 'Horários',
    'secretary': 'Secretaria Acadêmica',
    'library': 'Biblioteca',
    'eventos': 'Eventos',
  };

  @override
  Widget build(BuildContext context) {
    final info = MockRepository.campusInfo;
    final title = _titles[detailKey] ?? detailKey;

    String content;
    switch (detailKey) {
      case 'about':
        content = info['about'] as String;
      case 'address':
        content = '${info['address']}\n\nTelefone: ${info['phone']}\nE-mail: ${info['email']}';
      case 'hours':
        content = info['hours'] as String;
      default:
        content = 'Informações em breve.';
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          GreenHeroHeader(title: title, icon: Icons.location_city_rounded),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Text(content, style: Theme.of(context).textTheme.bodyLarge),
            ),
          ),
        ],
      ),
    );
  }
}
