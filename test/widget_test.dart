import 'package:flutter_test/flutter_test.dart';

import 'package:sand_gravel_app/main.dart';

void main() {
  testWidgets('renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TranspoGestApp());

    expect(find.text('TranspoGest'), findsOneWidget);
    expect(find.text('Connexion'), findsAtLeastNWidgets(1));
  });
}
