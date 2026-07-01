import 'dart:convert';

class UserSession {
  final String userId;
  final String identifier;
  final String fullName;
  final String email;
  final String role;
  final bool isActive;
  final String accessToken;
  final String refreshToken;

  const UserSession({
    required this.userId,
    required this.identifier,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isActive,
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
      email: (user['email'] ?? '').toString(),
      role: (user['role'] ?? '').toString(),
      isActive: _asBool(user['isActive'] ?? user['is_active'] ?? true),
      accessToken:
          (json['accessToken'] ?? json['access_token'] ?? json['token'] ?? '')
              .toString(),
      refreshToken: (json['refresh_token'] ?? '').toString(),
    );
  }

  UserSession copyWith({
    String? userId,
    String? identifier,
    String? fullName,
    String? email,
    String? role,
    bool? isActive,
    String? accessToken,
    String? refreshToken,
  }) {
    return UserSession(
      userId: userId ?? this.userId,
      identifier: identifier ?? this.identifier,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  UserSession mergeUserProfile(Map<String, dynamic> user) {
    return copyWith(
      userId: (user['user_id'] ?? user['id'] ?? userId).toString(),
      identifier:
          (user['identifier'] ?? user['phone'] ?? identifier).toString(),
      fullName: (user['full_name'] ?? user['name'] ?? fullName).toString(),
      email: (user['email'] ?? email).toString(),
      role: (user['role'] ?? role).toString(),
      isActive: _asBool(user['isActive'] ?? user['is_active'] ?? isActive),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'identifier': identifier,
      'full_name': fullName,
      'email': email,
      'role': role,
      'is_active': isActive,
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }

  String toStoragePayload() => jsonEncode(toJson());

  factory UserSession.fromStoragePayload(String payload) {
    return UserSession.fromJson(jsonDecode(payload) as Map<String, dynamic>);
  }

  static bool _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }

    switch (value?.toString().trim().toLowerCase()) {
      case 'true':
      case '1':
      case 'yes':
      case 'on':
        return true;
      case 'false':
      case '0':
      case 'no':
      case 'off':
        return false;
      default:
        return false;
    }
  }
}
