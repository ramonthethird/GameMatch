import 'package:flutter_test/flutter_test.dart';
import 'package:game_match/main.dart';

void main() {
  testWidgets('GameMatch title and welcome message are displayed',
      (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const GameMatchApp());

    // Verify that the title of the AppBar is displayed.
    expect(find.text('GameMatch Home'), findsOneWidget);

    // Verify that the welcome message is displayed.
    expect(find.text('Welcome to GameMatch!'), findsOneWidget);
  });
}
