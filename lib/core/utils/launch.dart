import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Abre uma URL externa no navegador. Prefixa https:// quando faltar.
Future<void> openExternalUrl(BuildContext context, String? raw) async {
  final messenger = ScaffoldMessenger.of(context);
  if (raw == null || raw.trim().isEmpty) {
    messenger.showSnackBar(const SnackBar(content: Text('Link indisponível')));
    return;
  }
  var url = raw.trim();
  if (!url.startsWith('http://') && !url.startsWith('https://')) url = 'https://$url';
  final uri = Uri.tryParse(url);
  final ok = uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok) messenger.showSnackBar(SnackBar(content: Text('Não foi possível abrir $url')));
}
