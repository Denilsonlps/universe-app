import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Salvar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          TextField(decoration: InputDecoration(labelText: 'Nome completo')),
          SizedBox(height: 16),
          TextField(decoration: InputDecoration(labelText: 'RA (Registro Acadêmico)')),
          SizedBox(height: 16),
          TextField(decoration: InputDecoration(labelText: 'Curso')),
          SizedBox(height: 16),
          TextField(decoration: InputDecoration(labelText: 'Semestre atual')),
        ],
      ),
    );
  }
}
