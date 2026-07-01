class RegisterRequest {
  final String name;
  final String phone;
  final String password;
  final String role;

  const RegisterRequest({
    required this.name,
    required this.phone,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'phone': phone.trim(),
      'password': password.trim(),
      'role': role.trim(),
    };
  }
}
