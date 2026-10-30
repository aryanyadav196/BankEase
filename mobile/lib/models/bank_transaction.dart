class BankTransaction {
  const BankTransaction({
    required this.id,
    required this.reference,
    required this.type,
    required this.amount,
    required this.status,
    required this.sourceAccountNumber,
    required this.destinationAccountNumber,
    required this.createdAt,
    required this.description,
  });
  final int id;
  final String reference;
  final String type;
  final double amount;
  final String status;
  final String? sourceAccountNumber;
  final String? destinationAccountNumber;
  final DateTime? createdAt;
  final String? description;

  factory BankTransaction.fromJson(Map<String, dynamic> json) =>
      BankTransaction(
        id: (json['id'] as num?)?.toInt() ?? 0,
        reference: json['transactionReference'] as String? ?? '',
        type: json['type'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        status: json['status'] as String? ?? '',
        sourceAccountNumber: json['sourceAccountNumber'] as String?,
        destinationAccountNumber: json['destinationAccountNumber'] as String?,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
        description: json['description'] as String?,
      );
}
