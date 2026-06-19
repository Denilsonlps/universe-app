import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Extensões de imagem aceitas no upload de conteúdo.
const acceptedImageExts = {'png', 'jpg', 'jpeg', 'svg'};

/// Detecta SVG pela URL (o caminho do Storage preserva a extensão antes do `?`).
bool isSvgUrl(String url) => url.toLowerCase().contains('.svg');

/// Renderiza uma imagem de conteúdo a partir de uma URL, suportando SVG
/// (vetorial, via flutter_svg) e formatos raster (PNG/JPEG, via cache de rede).
class ContentImage extends StatelessWidget {
  final String url;
  final double? height, width;
  final BoxFit fit;
  final Widget Function()? placeholder;
  final Widget Function()? error;
  const ContentImage(this.url, {super.key, this.height, this.width, this.fit = BoxFit.cover, this.placeholder, this.error});

  @override
  Widget build(BuildContext context) {
    if (isSvgUrl(url)) {
      return SvgPicture.network(
        url, height: height, width: width, fit: fit,
        placeholderBuilder: (_) => placeholder?.call() ?? const SizedBox.shrink(),
      );
    }
    return CachedNetworkImage(
      imageUrl: url, height: height, width: width, fit: fit,
      placeholder: placeholder == null ? null : (context, url) => placeholder!(),
      errorWidget: error == null ? null : (context, url, e) => error!(),
    );
  }
}
