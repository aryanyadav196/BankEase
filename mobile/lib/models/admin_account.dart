class AdminAccount {
  const AdminAccount({
    required this.id,
    required this.accountNumber,
    required this.accountType,
    required this.balance,
    required this.status,
    required this.customerName,
  });
  final int id;
  final String accountNumber;
  final String accountType;
  final double balance;
  final String status;
  final String? customerName;

  factory AdminAccount.fromJson(Map<String, dynamic> json) => AdminAccount(
    id: (json['id'] as num?)?.toInt() ?? 0,
    accountNumber: json['accountNumber'] as String? ?? '',
    accountType: json['accountType'] as String? ?? '',
    balance: (json['balance'] as num?)?.toDouble() ?? 0,
    status: json['status'] as String? ?? '',
    customerName: json['customerName'] as String?,
  );
}
