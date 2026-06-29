import 'dart:convert';

class UserSession {
  final String userId;
  final String identifier;
  final String fullName;
  final String accessToken;
  final String refreshToken;

  const UserSession({
    required this.userId,
    required this.identifier,
    required this.fullName,
    required this.accessToken,
    required this.refreshToken,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];
    final user = rawUser is Map<String, dynamic>
        ? rawUser
        : rawUser is Map
            ? Map<String, dynamic>.from(rawUser)
            : json;

    return UserSession(
      userId: (user['user_id'] ?? user['id'] ?? '').toString(),
      identifier: (user['identifier'] ?? user['phone'] ?? '').toString(),
      fullName: (user['full_name'] ?? user['name'] ?? 'Utilisateur').toString(),
      accessToken:
          (json['accessToken'] ?? json['access_token'] ?? json['token'] ?? '')
              .toString(),
      refreshToken: (json['refresh_token'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'identifier': identifier,
      'full_name': fullName,
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }

  String toStoragePayload() => jsonEncode(toJson());

  factory UserSession.fromStoragePayload(String payload) {
    return UserSession.fromJson(jsonDecode(payload) as Map<String, dynamic>);
  }
}
