import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'icon_tile.dart';

enum AppButtonVariant { primary, accent, outline, ghost }
enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool full;
  final String? icon;
  const AppButton(this.label, {super.key, this.onTap, this.variant = AppButtonVariant.primary, this.size = AppButtonSize.md, this.full = false, this.icon});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final dims = switch (size) {
      AppButtonSize.sm => (h: 38.0, fs: 13.0, px: 16.0, r: 11.0),
      AppButtonSize.md => (h: 50.0, fs: 15.0, px: 20.0, r: 14.0),
      AppButtonSize.lg => (h: 56.0, fs: 16.0, px: 24.0, r: 16.0),
    };
    final (bg, fg, border) = switch (variant) {
      AppButtonVariant.primary => (c.green800, Colors.white, null),
      AppButtonVariant.accent => (c.green500, Colors.white, null),
      AppButtonVariant.outline => (Colors.transparent, c.green800, c.green100),
      AppButtonVariant.ghost => (c.green050, c.green800, null),
    };
    return SizedBox(
      width: full ? double.infinity : null,
      height: dims.h,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(dims.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(dims.r),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: dims.px),
            decoration: border == null ? null : BoxDecoration(borderRadius: BorderRadius.circular(dims.r), border: Border.all(color: border, width: 1.5)),
            child: Row(
              mainAxisSize: full ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[Icon(appIcon(icon!), size: dims.fs + 4, color: fg), const SizedBox(width: 9)],
                Text(label, style: TextStyle(fontSize: dims.fs, fontWeight: FontWeight.w700, color: fg, letterSpacing: 0.2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
