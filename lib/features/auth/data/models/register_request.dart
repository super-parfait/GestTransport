class RegisterRequest {
  final String name;
  final String phone;
  final String email;
  final String password;

  const RegisterRequest({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    final trimmedEmail = email.trim();

    return {
      'name': name.trim(),
      'phone': phone.trim(),
      'password': password.trim(),
      if (trimmedEmail.isNotEmpty) 'email': trimmedEmail,
    };
  }
}
