class AuthSession {
  const AuthSession({
    required this.token,
    required this.email,
    required this.role,
  });

  final String token;
  final String email;
  final String role;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: json['token'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: (json['role'] as String? ?? '').toUpperCase(),
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'email': email,
    'role': role,
  };
}
