import '../../data/models/login_request.dart';
import '../../data/models/register_request.dart';
import '../../data/models/user_session.dart';

abstract class AuthRepository {
  Future<UserSession> register(RegisterRequest request);

  Future<UserSession> login(LoginRequest request);

  Future<UserSession?> restoreSession();

  Future<void> logout();
}
