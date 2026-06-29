import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/login_request.dart';
import '../models/user_session.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  const AuthRemoteDataSource(this._apiClient);

  Future<UserSession> login(LoginRequest request) {
    return _apiClient.post(
      ApiEndpoints.login,
      body: request.toJson(),
      decoder: (data) => UserSession.fromJson(data as Map<String, dynamic>),
    );
  }
}
