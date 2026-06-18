import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/icon_tile.dart';

({String watch, String? thumb})? parseVideoUrl(String? url) {
  if (url == null || url.trim().isEmpty) return null;
  final u = url.trim();
  final yt = RegExp(r'(?:youtube\.com/(?:watch\?v=|embed/|shorts/)|youtu\.be/)([\w-]{11})').firstMatch(u);
  if (yt != null) {
    final id = yt.group(1)!;
    return (watch: 'https://www.youtube.com/watch?v=$id', thumb: 'https://img.youtube.com/vi/$id/hqdefault.jpg');
  }
  final vimeo = RegExp(r'vimeo\.com/(\d+)').firstMatch(u);
  if (vimeo != null) return (watch: 'https://vimeo.com/${vimeo.group(1)}', thumb: null);
  if (u.startsWith('http')) return (watch: u, thumb: null);
  return null;
}

/// Renderiza imagem (URL) ou vídeo (link → thumbnail que abre no navegador).
class MediaView extends StatelessWidget {
  final String mediaType; // 'image' | 'video'
  final String? imageUrl, videoUrl, caption;
  const MediaView({super.key, required this.mediaType, this.imageUrl, this.videoUrl, this.caption});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final v = mediaType == 'video' ? parseVideoUrl(videoUrl) : null;
    Widget inner;
    if (mediaType == 'image' && imageUrl != null && imageUrl!.isNotEmpty) {
      inner = CachedNetworkImage(
        imageUrl: imageUrl!, height: 190, width: double.infinity, fit: BoxFit.cover,
        placeholder: (ctx, url) => Container(height: 190, color: c.bg2),
        errorWidget: (ctx, url, err) => _placeholder(c, false),
      );
    } else if (v != null) {
      inner = GestureDetector(
        onTap: () { final uri = Uri.tryParse(v.watch); if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication); },
        child: Stack(alignment: Alignment.center, children: [
          if (v.thumb != null) CachedNetworkImage(imageUrl: v.thumb!, height: 190, width: double.infinity, fit: BoxFit.cover, errorWidget: (ctx, url, err) => Container(height: 190, color: c.green900))
          else Container(height: 190, width: double.infinity, color: c.green900),
          Container(width: 60, height: 60, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(Icons.play_arrow, color: c.green800, size: 34)),
        ]),
      );
    } else {
      inner = _placeholder(c, mediaType == 'video');
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        inner,
        if (caption != null) Container(color: c.card, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), child: Text(caption!, style: TextStyle(fontSize: 12, color: c.ink2, fontWeight: FontWeight.w500))),
      ]),
    );
  }

  Widget _placeholder(AppColorsX c, bool isVideo) => Container(
    height: 150, color: c.bg2, alignment: Alignment.center,
    child: Icon(appIcon(isVideo ? 'globe' : 'doc'), size: 30, color: c.ink3),
  );
}
