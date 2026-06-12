import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/shared/brand/universe_brand.dart';

void main() {
  testWidgets('marca renderiza sem exceções', (t) async {
    await t.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Column(children: [
          UniverseMark(size: 64),
          UniverseBadge(size: 44),
          UniverseAppIcon(size: 96),
          UniverseWordmark(height: 28),
        ]),
      ),
    ));
    expect(find.byType(UniverseMark), findsWidgets);
    expect(find.byType(UniverseAppIcon), findsOneWidget);
    expect(find.text('UNI'), findsOneWidget);
    expect(find.text('RSE'), findsOneWidget);
  });
}
