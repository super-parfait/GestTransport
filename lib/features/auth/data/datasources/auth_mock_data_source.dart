import '../../../../core/network/api_exception.dart';
import '../models/login_request.dart';
import '../models/user_session.dart';

class AuthMockDataSource {
  const AuthMockDataSource();

  Future<UserSession> login(LoginRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (request.phone.trim().isEmpty || request.password.trim().isEmpty) {
      throw const ApiException('Identifiants incorrects. Veuillez réessayer.');
    }

    final identifier = request.phone.trim();

    return UserSession(
      userId: 'demo-user',
      identifier: identifier,
      fullName: 'Utilisateur ${identifier.replaceAll(RegExp(r'\s+'), ' ')}',
      accessToken: 'demo-access-token',
      refreshToken: 'demo-refresh-token',
    );
  }
}
