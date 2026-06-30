import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sand_gravel_app/core/constants/app_constants.dart';
import 'package:sand_gravel_app/core/config/app_config.dart';
import 'package:sand_gravel_app/core/network/api_client.dart';
import 'package:sand_gravel_app/core/network/api_exception.dart';
import 'package:sand_gravel_app/core/storage/token_storage.dart';
import 'package:sand_gravel_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:sand_gravel_app/features/auth/data/datasources/auth_mock_data_source.dart';
import 'package:sand_gravel_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:sand_gravel_app/features/auth/data/models/login_request.dart';
import 'package:sand_gravel_app/features/auth/data/models/register_request.dart';
import 'package:sand_gravel_app/features/auth/data/models/user_session.dart';
import 'package:sand_gravel_app/features/auth/data/repositories/auth_repository_impl.dart';

void main() {
  test('register does not fallback to mock when API mode returns 500',
      () async {
    SharedPreferences.setMockInitialValues({});
    _SpyAuthMockDataSource.registerCallCount = 0;
    final preferences = await SharedPreferences.getInstance();
    final repository = AuthRepositoryImpl(
      config: const AppConfig(
        baseUrl: 'http://127.0.0.1:3000/api/v1',
        connectTimeout: Duration(seconds: 30),
        receiveTimeout: Duration(seconds: 30),
        useMockApi: false,
        fallbackToMockOnError: true,
        enableNetworkLogs: false,
      ),
      remoteDataSource: _ThrowingAuthRemoteDataSource(
        _buildApiClient(preferences),
      ),
      mockDataSource: _SpyAuthMockDataSource(),
      localDataSource: AuthLocalDataSource(TokenStorage(preferences)),
    );

    expect(
      () => repository.register(
        const RegisterRequest(
          name: 'Test User',
          phone: '0711223344',
          email: 'test@example.com',
          password: 'secret123',
        ),
      ),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          'Internal server error',
        ),
      ),
    );

    expect(_SpyAuthMockDataSource.registerCallCount, 0);
    expect(preferences.getString(AppConstants.tokenKey), isNull);
  });
}

ApiClient _buildApiClient(SharedPreferences preferences) {
  return ApiClient(
    httpClient: http.Client(),
    tokenStorage: TokenStorage(preferences),
    config: const AppConfig(
      baseUrl: 'http://127.0.0.1:3000/api/v1',
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      useMockApi: false,
      fallbackToMockOnError: true,
      enableNetworkLogs: false,
    ),
  );
}

class _ThrowingAuthRemoteDataSource extends AuthRemoteDataSource {
  _ThrowingAuthRemoteDataSource(ApiClient apiClient) : super(apiClient);

  @override
  Future<UserSession> register(RegisterRequest request) async {
    throw const ApiException(
      'Internal server error',
      statusCode: 500,
    );
  }

  @override
  Future<UserSession> login(LoginRequest request) async {
    throw const ApiException(
      'Internal server error',
      statusCode: 500,
    );
  }
}

class _SpyAuthMockDataSource extends AuthMockDataSource {
  static int registerCallCount = 0;

  @override
  Future<UserSession> register(RegisterRequest request) async {
    registerCallCount += 1;
    return super.register(request);
  }
}
