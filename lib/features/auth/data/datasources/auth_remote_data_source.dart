import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_session.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  const AuthRemoteDataSource(this._apiClient);

  Future<UserSession> fetchCurrentUser(UserSession currentSession) {
    return _apiClient.get(
      ApiEndpoints.me,
      decoder: (data) {
        final user = data is Map<String, dynamic>
            ? data
            : Map<String, dynamic>.from(data as Map);
        return currentSession.mergeUserProfile(user);
      },
    );
  }

  Future<UserSession> register(RegisterRequest request) {
    return _apiClient.post(
      ApiEndpoints.register,
      body: request.toJson(),
      decoder: (data) => UserSession.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<UserSession> login(LoginRequest request) {
    return _apiClient.post(
      ApiEndpoints.login,
      body: request.toJson(),
      decoder: (data) => UserSession.fromJson(data as Map<String, dynamic>),
    );
  }
}
