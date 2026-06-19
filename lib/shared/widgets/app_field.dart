import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'icon_tile.dart';

class AppField extends StatefulWidget {
  final String? label, hint, icon, error;
  final String value;
  final ValueChanged<String> onChanged;
  final bool obscure, valid, multiline;
  final Widget? trailing;
  final TextInputType? keyboardType;
  const AppField({
    super.key, this.label, this.hint, this.icon, this.error,
    required this.value, required this.onChanged,
    this.obscure = false, this.valid = false, this.multiline = false, this.trailing, this.keyboardType,
  });

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  late final TextEditingController _ctrl = TextEditingController(text: widget.value);
  bool _focus = false;

  @override
  void didUpdateWidget(AppField old) {
    super.didUpdateWidget(old);
    if (widget.value != _ctrl.text) _ctrl.text = widget.value;
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final border = widget.error != null
        ? c.error
        : _focus ? c.green500 : widget.valid ? c.green400 : c.line;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (widget.label != null)
        Padding(
          padding: const EdgeInsets.only(left: 3, bottom: 7),
          child: Text(widget.label!, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.ink2)),
        ),
      Container(
        constraints: BoxConstraints(minHeight: widget.multiline ? 92 : 50),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: widget.multiline ? 12 : 0),
        decoration: BoxDecoration(
          color: c.card, borderRadius: BorderRadius.circular(13),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Row(crossAxisAlignment: widget.multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center, children: [
          if (widget.icon != null) ...[
            Icon(appIcon(widget.icon!), size: 19, color: _focus ? c.green600 : c.ink3),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Focus(
              onFocusChange: (f) => setState(() => _focus = f),
              child: TextField(
                controller: _ctrl,
                onChanged: widget.onChanged,
                obscureText: widget.obscure,
                keyboardType: widget.multiline ? TextInputType.multiline : widget.keyboardType,
                minLines: widget.multiline ? 3 : 1,
                maxLines: widget.multiline ? null : 1,
                style: TextStyle(fontSize: 15, color: c.ink, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  isCollapsed: true, border: InputBorder.none,
                  hintText: widget.hint,
                  hintStyle: TextStyle(fontSize: 14, color: c.ink3, fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ),
          if (widget.valid && widget.trailing == null) Icon(Icons.check, size: 18, color: c.green500),
          if (widget.trailing != null) widget.trailing!,
        ]),
      ),
      if (widget.error != null)
        Padding(
          padding: const EdgeInsets.only(left: 3, top: 6),
          child: Text(widget.error!, style: TextStyle(fontSize: 11.5, color: c.error, fontWeight: FontWeight.w600)),
        ),
    ]);
  }
}

class PasswordField extends StatefulWidget {
  final String? label, hint, error;
  final String value;
  final ValueChanged<String> onChanged;
  final bool valid;
  const PasswordField({super.key, this.label, this.hint, this.error, required this.value, required this.onChanged, this.valid = false});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _show = false;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AppField(
      label: widget.label, hint: widget.hint, error: widget.error, icon: 'shield',
      value: widget.value, onChanged: widget.onChanged, valid: widget.valid, obscure: !_show,
      trailing: InkWell(
        onTap: () => setState(() => _show = !_show),
        child: Icon(_show ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 19, color: c.ink3),
      ),
    );
  }
}
