import '../../../../core/config/app_config.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_mock_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_session.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AppConfig _config;
  final AuthRemoteDataSource _remoteDataSource;
  final AuthMockDataSource _mockDataSource;
  final AuthLocalDataSource _localDataSource;

  const AuthRepositoryImpl({
    required AppConfig config,
    required AuthRemoteDataSource remoteDataSource,
    required AuthMockDataSource mockDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _config = config,
        _remoteDataSource = remoteDataSource,
        _mockDataSource = mockDataSource,
        _localDataSource = localDataSource;

  @override
  Future<UserSession> register(RegisterRequest request) async {
    final session = _config.useMockApi
        ? await _mockDataSource.register(request)
        : await _remoteDataSource.register(request);
    await _localDataSource.saveSession(session);
    return session;
  }

  @override
  Future<UserSession> login(LoginRequest request) async {
    final session = _config.useMockApi
        ? await _mockDataSource.login(request)
        : await _remoteDataSource.login(request);
    await _localDataSource.saveSession(session);
    return session;
  }

  @override
  Future<UserSession?> restoreSession() {
    return _localDataSource.readSession();
  }

  @override
  Future<void> logout() {
    return _localDataSource.clearSession();
  }
}
