import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/providers/repository_provider.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_field.dart';
import '../widgets/icon_tile.dart';
import 'content_image.dart';

/// Campo reutilizável para definir UMA imagem: upload ao Storage OU link.
/// Mostra preview, valida o formato (PNG/JPEG/SVG) e indica progresso/erro.
class ImagePickerField extends ConsumerStatefulWidget {
  final String? imageUrl;
  final ValueChanged<String?> onChanged; // null = imagem removida
  final BoxFit previewFit;
  const ImagePickerField({super.key, required this.imageUrl, required this.onChanged, this.previewFit = BoxFit.cover});

  @override
  ConsumerState<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends ConsumerState<ImagePickerField> {
  bool _uploading = false;
  String? _error;

  Future<void> _pick() async {
    setState(() => _error = null);
    try {
      final x = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (x == null) return;
      final ext = (x.name.contains('.') ? x.name.split('.').last : '').toLowerCase();
      if (!acceptedImageExts.contains(ext)) {
        setState(() => _error = 'Formato não suportado. Use PNG, JPEG ou SVG.');
        return;
      }
      setState(() => _uploading = true);
      final bytes = await x.readAsBytes();
      final url = await ref.read(storageServiceProvider).uploadContentImage(bytes, ext: ext);
      widget.onChanged(url);
    } catch (_) {
      setState(() => _error = 'Falha no upload. Tente novamente.');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final hasImage = widget.imageUrl != null && widget.imageUrl!.isNotEmpty;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (hasImage)
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: c.bg2,
            height: 150,
            width: double.infinity,
            child: ContentImage(widget.imageUrl!, height: 150, width: double.infinity, fit: widget.previewFit),
          ),
        ),
      const SizedBox(height: 9),
      Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: _uploading ? null : _pick,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: c.green050, borderRadius: BorderRadius.circular(11)),
              child: _uploading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(appIcon('plus'), size: 17, color: c.green700),
                      const SizedBox(width: 7),
                      Text(hasImage ? 'Trocar imagem' : 'Escolher imagem', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.green700)),
                    ]),
            ),
          ),
        ),
        if (hasImage) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: _uploading ? null : () => widget.onChanged(null),
            icon: Icon(Icons.delete_outline, size: 20, color: c.error),
            tooltip: 'Remover imagem',
          ),
        ],
      ]),
      const SizedBox(height: 6),
      Text('Formatos aceitos: PNG, JPEG ou SVG.', style: TextStyle(fontSize: 11.5, color: c.ink3)),
      if (_error != null) Padding(padding: const EdgeInsets.only(top: 7), child: Text(_error!, style: TextStyle(fontSize: 11.5, color: c.error, fontWeight: FontWeight.w600))),
      const SizedBox(height: 11),
      AppField(
        label: 'ou cole o link de uma imagem',
        icon: 'globe',
        value: widget.imageUrl ?? '',
        onChanged: (v) => widget.onChanged(v.trim().isEmpty ? null : v.trim()),
      ),
    ]);
  }
}
