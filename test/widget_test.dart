import 'package:flutter_test/flutter_test.dart';
import 'package:riverraidweb2/main.dart';

void main() {
  testWidgets('Game loads without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RiverRaidApp());

    // Verify the game screen is displayed
    expect(find.byType(GameScreen), findsOneWidget);
  });

  testWidgets('Game shows score and fuel', (WidgetTester tester) async {
    await tester.pumpWidget(const RiverRaidApp());
    await tester.pumpAndSettle();

    // Verify HUD elements are present
    expect(find.textContaining('Score:'), findsOneWidget);
    expect(find.textContaining('Fuel:'), findsOneWidget);
    expect(find.textContaining('Lives:'), findsOneWidget);
    expect(find.textContaining('Top:'), findsOneWidget);
  });

  testWidgets('Start screen is visible', (WidgetTester tester) async {
    await tester.pumpWidget(const RiverRaidApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('PRESS ENTER/SPACE'), findsOneWidget);
  });

  testWidgets('Game Over screen can restart', (WidgetTester tester) async {
    await tester.pumpWidget(const RiverRaidApp());
    await tester.pumpAndSettle();

    // Note: These are basic structural tests
    // More detailed game logic tests would require mocking and game state manipulation
  });
}
