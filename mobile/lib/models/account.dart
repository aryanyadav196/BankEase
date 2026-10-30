class BankAccount {
  const BankAccount({
    required this.id,
    required this.accountNumber,
    required this.accountType,
    required this.balance,
    required this.status,
  });
  final int id;
  final String accountNumber;
  final String accountType;
  final double balance;
  final String status;

  factory BankAccount.fromJson(Map<String, dynamic> json) => BankAccount(
    id: (json['id'] as num?)?.toInt() ?? 0,
    accountNumber: json['accountNumber'] as String? ?? '',
    accountType: json['accountType'] as String? ?? '',
    balance: (json['balance'] as num?)?.toDouble() ?? 0,
    status: json['status'] as String? ?? '',
  );
}
