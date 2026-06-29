import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class AppEnvironment {
  static const String fileName = '.env';

  static Future<void> load() {
    return dotenv.load(
      fileName: fileName,
      isOptional: true,
    );
  }
}
