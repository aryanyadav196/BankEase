class CustomerProfile {
  const CustomerProfile({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.email,
  });
  final int id;
  final String fullName;
  final String phone;
  final String? address;
  final String email;

  factory CustomerProfile.fromJson(Map<String, dynamic> json) =>
      CustomerProfile(
        id: (json['id'] as num?)?.toInt() ?? 0,
        fullName: json['fullName'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        address: json['address'] as String?,
        email: json['email'] as String? ?? '',
      );
}
