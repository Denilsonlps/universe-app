import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

const double kStatusH = 50;
const double kNavH = 64;

/// Casca de página: header fixo + corpo rolável.
class PageShell extends StatelessWidget {
  final Widget? header;
  final Widget body;
  final Widget? bottomNav;
  final EdgeInsets bodyPadding;
  const PageShell({super.key, this.header, required this.body, this.bottomNav, this.bodyPadding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      color: c.bg,
      child: Column(children: [
        ?header,
        Expanded(
          child: SingleChildScrollView(
            padding: bodyPadding.copyWith(bottom: bodyPadding.bottom + (bottomNav != null ? kNavH + 28 : 28)),
            child: body,
          ),
        ),
        ?bottomNav,
      ]),
    );
  }
}
