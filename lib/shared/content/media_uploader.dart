import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_field.dart';
import 'image_picker_field.dart';

/// Editor de mídia de uma seção: imagem (upload/link) ou vídeo (link).
class MediaUploader extends StatelessWidget {
  final String mediaType; // 'image' | 'video'
  final String? imageUrl, videoUrl;
  final String fit; // 'cover' | 'contain' — só afeta o preview da imagem
  final void Function({required String mediaType, String? imageUrl, String? videoUrl}) onChange;
  const MediaUploader({super.key, required this.mediaType, this.imageUrl, this.videoUrl, this.fit = 'cover', required this.onChange});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final isImage = mediaType == 'image';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Alternância imagem / vídeo
      Row(children: [
        for (final opt in const [('image', 'Imagem'), ('video', 'Vídeo')])
          Expanded(child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChange(mediaType: opt.$1, imageUrl: imageUrl, videoUrl: videoUrl),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: mediaType == opt.$1 ? c.green800 : c.bg2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(opt.$2, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: mediaType == opt.$1 ? Colors.white : c.ink2)),
              ),
            ),
          )),
      ]),
      const SizedBox(height: 11),
      if (isImage)
        ImagePickerField(
          imageUrl: imageUrl,
          previewFit: fit == 'contain' ? BoxFit.contain : BoxFit.cover,
          onChanged: (url) => onChange(mediaType: 'image', imageUrl: url, videoUrl: null),
        )
      else
        AppField(
          label: 'Link do vídeo (YouTube/Vimeo)', icon: 'globe',
          value: videoUrl ?? '',
          onChanged: (v) => onChange(mediaType: 'video', imageUrl: null, videoUrl: v),
        ),
    ]);
  }
}
