import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Notificações')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none_rounded, size: 64, color: AppColors.ink3),
            SizedBox(height: 12),
            Text('Nenhuma notificação', style: TextStyle(color: AppColors.ink3)),
          ],
        ),
      ),
    );
  }
}
