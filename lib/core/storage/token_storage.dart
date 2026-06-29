import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class TokenStorage {
  final SharedPreferences _preferences;

  const TokenStorage(this._preferences);

  String? readAccessToken() => _preferences.getString(AppConstants.tokenKey);

  String? readRefreshToken() =>
      _preferences.getString(AppConstants.refreshTokenKey);

  String? readUserPayload() => _preferences.getString(AppConstants.userKey);

  Future<void> saveSession({
    required String accessToken,
    String? refreshToken,
    required String userPayload,
  }) async {
    await _preferences.setString(AppConstants.tokenKey, accessToken);
    await _preferences.setString(
      AppConstants.refreshTokenKey,
      refreshToken ?? '',
    );
    await _preferences.setString(AppConstants.userKey, userPayload);
  }

  Future<void> clearSession() async {
    await _preferences.remove(AppConstants.tokenKey);
    await _preferences.remove(AppConstants.refreshTokenKey);
    await _preferences.remove(AppConstants.userKey);
  }
}
