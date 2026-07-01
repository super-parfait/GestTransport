import '../../../../core/network/api_exception.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_session.dart';

class AuthMockDataSource {
  const AuthMockDataSource();

  Future<UserSession> register(RegisterRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (request.name.trim().isEmpty ||
        request.phone.trim().isEmpty ||
        request.password.trim().isEmpty ||
        request.role.trim().isEmpty) {
      throw const ApiException('Informations d’inscription incomplètes.');
    }

    if (request.phone.trim() == '0700000000') {
      throw const ApiException('Ce téléphone est déjà utilisé.');
    }

    return UserSession(
      userId: 'demo-user-${request.phone.trim()}',
      identifier: request.phone.trim(),
      fullName: request.name.trim(),
      email: '',
      role: request.role.trim(),
      isActive: true,
      accessToken: 'demo-access-token',
      refreshToken: 'demo-refresh-token',
    );
  }

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
      email: '',
      role: 'VIEWER',
      isActive: true,
      accessToken: 'demo-access-token',
      refreshToken: 'demo-refresh-token',
    );
  }
}
