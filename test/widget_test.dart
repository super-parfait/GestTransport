import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sand_gravel_app/app/transpo_gest_app.dart';
import 'package:sand_gravel_app/core/config/app_config.dart';
import 'package:sand_gravel_app/core/config/app_environment.dart';
import 'package:sand_gravel_app/core/di/app_container.dart';
import 'package:sand_gravel_app/features/auth/data/models/login_request.dart';
import 'package:sand_gravel_app/features/auth/data/models/register_request.dart';
import 'package:sand_gravel_app/features/auth/data/models/user_session.dart';
import 'package:sand_gravel_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:sand_gravel_app/features/auth/presentation/controllers/session_controller.dart';
import 'package:sand_gravel_app/features/auth/presentation/login_screen.dart';
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

  testWidgets('shows a single loading spinner during login submission',
      (WidgetTester tester) async {
    final repository = _PendingAuthRepository();
    final controller = SessionController(repository);

    await tester.binding.setSurfaceSize(const Size(411, 915));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(sessionController: controller),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).at(0), '0711223344');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
    await tester.ensureVisible(find.text('Connexion').last);
    await tester.tap(find.text('Connexion').last);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Connexion en cours...'), findsOneWidget);

    repository.completeLogin();
    await tester.pumpAndSettle();
  });
}

class _PendingAuthRepository implements AuthRepository {
  final Completer<UserSession> _loginCompleter = Completer<UserSession>();

  @override
  Future<UserSession> login(LoginRequest request) => _loginCompleter.future;

  void completeLogin() {
    if (_loginCompleter.isCompleted) {
      return;
    }

    _loginCompleter.complete(
      const UserSession(
        userId: 'test-user',
        identifier: '0711223344',
        fullName: 'Utilisateur Test',
        email: '',
        role: 'MANAGER',
        isActive: true,
        accessToken: 'token',
        refreshToken: 'refresh',
      ),
    );
  }

  @override
  Future<UserSession> register(RegisterRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<UserSession?> restoreSession() async => null;

  @override
  Future<void> logout() async {}
}
