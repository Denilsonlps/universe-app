import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/providers/repository_provider.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_field.dart';
import '../widgets/icon_tile.dart';
import 'content_image.dart';

/// Editor de mídia de uma seção: imagem (upload) ou vídeo (link).
class MediaUploader extends ConsumerStatefulWidget {
  final String mediaType; // 'image' | 'video'
  final String? imageUrl, videoUrl;
  final void Function({required String mediaType, String? imageUrl, String? videoUrl}) onChange;
  const MediaUploader({super.key, required this.mediaType, this.imageUrl, this.videoUrl, required this.onChange});

  @override
  ConsumerState<MediaUploader> createState() => _MediaUploaderState();
}

class _MediaUploaderState extends ConsumerState<MediaUploader> {
  bool _uploading = false;
  String? _error;

  Future<void> _pick() async {
    setState(() { _error = null; });
    try {
      // Sem maxWidth/imageQuality: o redimensionamento re-encoda a imagem e quebra
      // arquivos vetoriais (SVG). Mantemos os bytes originais.
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
      widget.onChange(mediaType: 'image', imageUrl: url, videoUrl: null);
    } catch (e) {
      setState(() => _error = 'Falha no upload. Tente novamente.');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final isImage = widget.mediaType == 'image';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Alternância imagem / vídeo
      Row(children: [
        for (final opt in const [('image', 'Imagem'), ('video', 'Vídeo')])
          Expanded(child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => widget.onChange(mediaType: opt.$1, imageUrl: widget.imageUrl, videoUrl: widget.videoUrl),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.mediaType == opt.$1 ? c.green800 : c.bg2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(opt.$2, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: widget.mediaType == opt.$1 ? Colors.white : c.ink2)),
              ),
            ),
          )),
      ]),
      const SizedBox(height: 11),
      if (isImage) ...[
        if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
          ClipRRect(borderRadius: BorderRadius.circular(12), child: ContentImage(widget.imageUrl!, height: 150, width: double.infinity)),
        const SizedBox(height: 9),
        GestureDetector(
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
                    Text(widget.imageUrl == null ? 'Escolher imagem' : 'Trocar imagem', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.green700)),
                  ]),
          ),
        ),
        const SizedBox(height: 6),
        Text('Formatos aceitos: PNG, JPEG ou SVG.', style: TextStyle(fontSize: 11.5, color: c.ink3)),
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 7), child: Text(_error!, style: TextStyle(fontSize: 11.5, color: c.error, fontWeight: FontWeight.w600))),
      ] else
        AppField(
          label: 'Link do vídeo (YouTube/Vimeo)', icon: 'globe',
          value: widget.videoUrl ?? '',
          onChanged: (v) => widget.onChange(mediaType: 'video', imageUrl: null, videoUrl: v),
        ),
    ]);
  }
}
