import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sand_gravel_app/app/transpo_gest_app.dart';
import 'package:sand_gravel_app/core/config/app_environment.dart';
import 'package:sand_gravel_app/core/di/app_container.dart';

void main() {
  testWidgets('renders login screen', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await AppEnvironment.load();
    SharedPreferences.setMockInitialValues({});
    final container = await AppContainer.bootstrap();

    await tester.pumpWidget(TranspoGestApp(container: container));
    await tester.pumpAndSettle();

    expect(find.text('TranspoGest'), findsOneWidget);
    expect(find.text('Connexion'), findsAtLeastNWidgets(1));
  });
}
