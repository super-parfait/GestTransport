import '../../../../core/storage/token_storage.dart';
import '../models/user_session.dart';

class AuthLocalDataSource {
  final TokenStorage _tokenStorage;

  const AuthLocalDataSource(this._tokenStorage);

  Future<void> saveSession(UserSession session) {
    return _tokenStorage.saveSession(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      userPayload: session.toStoragePayload(),
    );
  }

  Future<UserSession?> readSession() async {
    final payload = _tokenStorage.readUserPayload();
    if (payload == null || payload.isEmpty) {
      return null;
    }

    return UserSession.fromStoragePayload(payload);
  }

  Future<void> clearSession() => _tokenStorage.clearSession();
}
