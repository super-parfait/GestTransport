import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/di/app_container.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/controllers/session_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/main_scaffold.dart';

class TranspoGestApp extends StatelessWidget {
  final AppContainer container;

  const TranspoGestApp({
    super.key,
    required this.container,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _AppRoot(container: container),
    );
  }
}

class _AppRoot extends StatefulWidget {
  final AppContainer container;

  const _AppRoot({required this.container});

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  @override
  void initState() {
    super.initState();
    widget.container.sessionController.restoreSession();
  }

  @override
  void dispose() {
    widget.container.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.container.sessionController,
      builder: (context, _) {
        final status = widget.container.sessionController.status;

        if (status == SessionStatus.loading) {
          return const _BootstrapScreen();
        }

        if (status == SessionStatus.authenticated) {
          return MainScaffold(container: widget.container);
        }

        return LoginScreen(
          sessionController: widget.container.sessionController,
        );
      },
    );
  }
}

class _BootstrapScreen extends StatelessWidget {
  const _BootstrapScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
