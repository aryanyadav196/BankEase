class EmployeeCustomer {
  const EmployeeCustomer({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
  });

  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String? address;

  factory EmployeeCustomer.fromJson(Map<String, dynamic> json) =>
      EmployeeCustomer(
        id: (json['id'] as num?)?.toInt() ?? 0,
        fullName: json['fullName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        address: json['address'] as String?,
      );
}
