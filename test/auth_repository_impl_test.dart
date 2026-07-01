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
          password: 'secret123',
          role: 'MANAGER',
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

  test('restoreSession refreshes the connected user profile from auth me',
      () async {
    final storedSession = UserSession(
      userId: 'stored-id',
      identifier: '0700000000',
      fullName: 'Stored User',
      email: '',
      role: '',
      isActive: true,
      accessToken: 'stored-access-token',
      refreshToken: 'stored-refresh-token',
    );

    SharedPreferences.setMockInitialValues({
      AppConstants.tokenKey: storedSession.accessToken,
      AppConstants.refreshTokenKey: storedSession.refreshToken,
      AppConstants.userKey: storedSession.toStoragePayload(),
    });

    final preferences = await SharedPreferences.getInstance();
    final repository = AuthRepositoryImpl(
      config: const AppConfig(
        baseUrl: 'http://127.0.0.1:3000/api/v1',
        connectTimeout: Duration(seconds: 30),
        receiveTimeout: Duration(seconds: 30),
        useMockApi: false,
        fallbackToMockOnError: false,
        enableNetworkLogs: false,
      ),
      remoteDataSource: _RefreshingAuthRemoteDataSource(
        _buildApiClient(preferences),
      ),
      mockDataSource: const AuthMockDataSource(),
      localDataSource: AuthLocalDataSource(TokenStorage(preferences)),
    );

    final refreshedSession = await repository.restoreSession();

    expect(refreshedSession, isNotNull);
    expect(refreshedSession!.userId, 'api-user-id');
    expect(refreshedSession.fullName, 'Utilisateur API');
    expect(refreshedSession.identifier, '0711223344');
    expect(refreshedSession.email, 'api@example.com');
    expect(refreshedSession.role, 'ADMIN');
    expect(refreshedSession.isActive, isTrue);
    expect(refreshedSession.accessToken, storedSession.accessToken);
    expect(refreshedSession.refreshToken, storedSession.refreshToken);

    final persistedPayload = preferences.getString(AppConstants.userKey);
    expect(persistedPayload, isNotNull);
    final persistedSession = UserSession.fromStoragePayload(persistedPayload!);
    expect(persistedSession.fullName, 'Utilisateur API');
    expect(persistedSession.email, 'api@example.com');
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

class _RefreshingAuthRemoteDataSource extends AuthRemoteDataSource {
  _RefreshingAuthRemoteDataSource(ApiClient apiClient) : super(apiClient);

  @override
  Future<UserSession> fetchCurrentUser(UserSession currentSession) async {
    return currentSession.mergeUserProfile({
      'id': 'api-user-id',
      'name': 'Utilisateur API',
      'phone': '0711223344',
      'email': 'api@example.com',
      'role': 'ADMIN',
      'isActive': true,
    });
  }
}
