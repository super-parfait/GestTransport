import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sand_gravel_app/app/transpo_gest_app.dart';
import 'package:sand_gravel_app/core/config/app_config.dart';
import 'package:sand_gravel_app/core/config/app_environment.dart';
import 'package:sand_gravel_app/core/di/app_container.dart';
import 'package:sand_gravel_app/features/main_scaffold.dart';

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

  testWidgets('keeps main navigation in the lower half of the screen',
      (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    final container = await AppContainer.bootstrap(
      config: const AppConfig(
        baseUrl: 'http://127.0.0.1:3000/api/v1',
        connectTimeout: Duration(seconds: 30),
        receiveTimeout: Duration(seconds: 30),
        useMockApi: true,
        fallbackToMockOnError: true,
        enableNetworkLogs: false,
      ),
    );

    await tester.binding.setSurfaceSize(const Size(411, 915));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MainScaffold(container: container),
      ),
    );
    await tester.pumpAndSettle();

    final navItem = find.text('Accueil').first;
    final navPosition = tester.getTopLeft(navItem);

    expect(navPosition.dy, greaterThan(600));

    container.dispose();
  });
}
