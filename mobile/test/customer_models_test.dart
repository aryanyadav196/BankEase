import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/models/account.dart';
import 'package:mobile/models/bank_transaction.dart';
import 'package:mobile/models/customer_profile.dart';
import 'package:mobile/models/service_request.dart';

void main() {
  test('customer profile response is parsed from backend fields', () {
    final profile = CustomerProfile.fromJson({
      'id': 7,
      'fullName': 'Sample Customer',
      'phone': '0000000000',
      'address': 'Sample address',
      'email': 'sample@example.com',
    });

    expect(profile.id, 7);
    expect(profile.fullName, 'Sample Customer');
    expect(profile.email, 'sample@example.com');
  });

  test('account, transaction, and service request responses are parsed', () {
    final account = BankAccount.fromJson({
      'id': 3,
      'accountNumber': '100000ABC123',
      'accountType': 'SAVINGS',
      'balance': 1250.50,
      'status': 'ACTIVE',
    });
    final transaction = BankTransaction.fromJson({
      'id': 4,
      'transactionReference': 'TXN-SAMPLE',
      'type': 'DEPOSIT',
      'amount': 100.0,
      'status': 'COMPLETED',
      'sourceAccountNumber': null,
      'destinationAccountNumber': '100000ABC123',
      'createdAt': '2026-01-01T10:00:00',
      'description': 'Sample transaction',
    });
    final request = CustomerServiceRequest.fromJson({
      'id': 5,
      'type': 'GENERAL_QUERY',
      'status': 'PENDING',
      'priority': 'MEDIUM',
      'description': 'Sample request',
      'createdAt': '2026-01-01T10:00:00',
      'updatedAt': '2026-01-01T10:00:00',
    });

    expect(account.balance, 1250.50);
    expect(transaction.reference, 'TXN-SAMPLE');
    expect(transaction.createdAt, isNotNull);
    expect(request.type, 'GENERAL_QUERY');
    expect(request.status, 'PENDING');
  });
}
