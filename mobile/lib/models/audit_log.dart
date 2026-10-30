class AuditLog {
  const AuditLog({
    required this.id,
    required this.action,
    required this.ruleType,
    required this.description,
    required this.result,
    required this.createdAt,
    required this.user,
  });
  final int id;
  final String action;
  final String? ruleType;
  final String description;
  final String result;
  final DateTime? createdAt;
  final String? user;

  factory AuditLog.fromJson(Map<String, dynamic> json) => AuditLog(
    id: (json['id'] as num?)?.toInt() ?? 0,
    action: json['action'] as String? ?? '',
    ruleType: json['ruleType'] as String?,
    description: json['description'] as String? ?? '',
    result: json['result'] as String? ?? '',
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    user: json['user'] as String?,
  );
}
