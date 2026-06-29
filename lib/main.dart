import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/transpo_gest_app.dart';
import 'core/config/app_environment.dart';
import 'core/di/app_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppEnvironment.load();
  final container = await AppContainer.bootstrap();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(TranspoGestApp(container: container));
}
