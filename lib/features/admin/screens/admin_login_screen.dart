import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green900,
      appBar: AppBar(
        backgroundColor: AppColors.green900,
        title: const Text('Admin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Acesso Administrativo',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 32),
            const TextField(
              decoration: InputDecoration(labelText: 'E-mail admin'),
            ),
            const SizedBox(height: 16),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Senha'),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () => context.go('/admin/panel'),
              child: const Text('Entrar como admin'),
            ),
          ],
        ),
      ),
    );
  }
}
