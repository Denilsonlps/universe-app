import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universe_app/main.dart';

void main() {
  testWidgets('app sobe e mostra a aba Início', (t) async {
    SharedPreferences.setMockInitialValues({});
    await t.pumpWidget(const ProviderScope(child: UniverseApp()));
    await t.pumpAndSettle();
    expect(find.text('UNIVERSE'), findsOneWidget);
    expect(find.text('Início'), findsWidgets);
  });
}
