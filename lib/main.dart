import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/main_scaffold.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const TranspoGestApp());
}

class TranspoGestApp extends StatelessWidget {
  const TranspoGestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TranspoGest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();
  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  bool _isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return _isLoggedIn
        ? const MainScaffold()
        : LoginScreen(onLoginSuccess: () => setState(() => _isLoggedIn = true));
  }
}
