class AutomationRule {
  const AutomationRule({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.active,
  });
  final int id;
  final String name;
  final String type;
  final String description;
  final bool active;

  factory AutomationRule.fromJson(Map<String, dynamic> json) => AutomationRule(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    type: json['type'] as String? ?? '',
    description: json['description'] as String? ?? '',
    active: json['active'] as bool? ?? false,
  );
}
