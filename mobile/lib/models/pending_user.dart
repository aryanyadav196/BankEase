class PendingUser {
  const PendingUser({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
  });
  final int id;
  final String email;
  final String role;
  final String status;

  factory PendingUser.fromJson(Map<String, dynamic> json) => PendingUser(
    id: (json['id'] as num?)?.toInt() ?? 0,
    email: json['email'] as String? ?? '',
    role: json['role'] as String? ?? '',
    status: json['status'] as String? ?? '',
  );
}
