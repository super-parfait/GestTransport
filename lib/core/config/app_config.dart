import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final bool useMockApi;
  final bool fallbackToMockOnError;
  final bool enableNetworkLogs;

  const AppConfig({
    required this.baseUrl,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.useMockApi,
    required this.fallbackToMockOnError,
    required this.enableNetworkLogs,
  });

  factory AppConfig.fromEnvironment() {
    final env = dotenv.isInitialized ? dotenv.env : const <String, String>{};

    return AppConfig(
      baseUrl: _readString(
        env,
        'API_BASE_URL',
        fallback: const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://api.yourdomain.com/api/v1',
        ),
      ),
      connectTimeout: Duration(
        milliseconds: _readInt(
          env,
          'API_CONNECT_TIMEOUT_MS',
          fallback: const int.fromEnvironment(
            'API_CONNECT_TIMEOUT_MS',
            defaultValue: 30000,
          ),
        ),
      ),
      receiveTimeout: Duration(
        milliseconds: _readInt(
          env,
          'API_RECEIVE_TIMEOUT_MS',
          fallback: const int.fromEnvironment(
            'API_RECEIVE_TIMEOUT_MS',
            defaultValue: 30000,
          ),
        ),
      ),
      useMockApi: _readBool(
        env,
        'USE_MOCK_API',
        fallback: const bool.fromEnvironment(
          'USE_MOCK_API',
          defaultValue: true,
        ),
      ),
      fallbackToMockOnError: _readBool(
        env,
        'FALLBACK_TO_MOCK_ON_ERROR',
        fallback: const bool.fromEnvironment(
          'FALLBACK_TO_MOCK_ON_ERROR',
          defaultValue: true,
        ),
      ),
      enableNetworkLogs: _readBool(
        env,
        'ENABLE_NETWORK_LOGS',
        fallback: const bool.fromEnvironment(
          'ENABLE_NETWORK_LOGS',
          defaultValue: true,
        ),
      ),
    );
  }

  static String _readString(
    Map<String, String> env,
    String key, {
    required String fallback,
  }) {
    final value = env[key]?.trim();
    if (value == null || value.isEmpty) {
      return fallback;
    }

    return value;
  }

  static int _readInt(
    Map<String, String> env,
    String key, {
    required int fallback,
  }) {
    final value = env[key]?.trim();
    return int.tryParse(value ?? '') ?? fallback;
  }

  static bool _readBool(
    Map<String, String> env,
    String key, {
    required bool fallback,
  }) {
    final value = env[key]?.trim().toLowerCase();
    switch (value) {
      case 'true':
      case '1':
      case 'yes':
      case 'on':
        return true;
      case 'false':
      case '0':
      case 'no':
      case 'off':
        return false;
      default:
        return fallback;
    }
  }

  String resolvePath(String path) {
    final sanitizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final sanitizedPath = path.startsWith('/') ? path.substring(1) : path;

    return '$sanitizedBase/$sanitizedPath';
  }

  String get dataSourceLabel => useMockApi ? 'Mode démo' : 'API';
}
