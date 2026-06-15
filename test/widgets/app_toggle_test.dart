import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/shared/widgets/app_toggle.dart';

void main() {
  testWidgets('AppToggle emite onChanged ao tocar', (t) async {
    var on = false;
    await t.pumpWidget(MaterialApp(theme: AppTheme.light, home: Scaffold(body: Center(
      child: StatefulBuilder(builder: (c, setState) => AppToggle(on: on, onChanged: (v) => setState(() => on = v))),
    ))));
    expect(on, isFalse);
    await t.tap(find.byType(AppToggle));
    await t.pumpAndSettle();
    expect(on, isTrue);
  });
}
