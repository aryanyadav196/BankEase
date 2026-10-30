class CustomerServiceRequest {
  const CustomerServiceRequest({
    required this.id,
    required this.type,
    required this.status,
    required this.priority,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });
  final int id;
  final String type;
  final String status;
  final String priority;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CustomerServiceRequest.fromJson(Map<String, dynamic> json) =>
      CustomerServiceRequest(
        id: (json['id'] as num?)?.toInt() ?? 0,
        type: json['type'] as String? ?? '',
        status: json['status'] as String? ?? '',
        priority: json['priority'] as String? ?? '',
        description: json['description'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      );
}
