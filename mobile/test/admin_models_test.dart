import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/models/admin_account.dart';
import 'package:mobile/models/admin_overview.dart';
import 'package:mobile/models/audit_log.dart';
import 'package:mobile/models/automation_rule.dart';
import 'package:mobile/models/pending_user.dart';

void main() {
  test('admin response models parse verified backend fields', () {
    final overview = AdminOverview.fromJson({
      'totalUsers': 10,
      'totalCustomers': 7,
      'totalAccounts': 8,
      'totalTransactions': 12,
      'pendingServiceRequests': 2,
      'blockedAccounts': 1,
      'rejectedTransactions': 3,
      'totalAuditLogs': 9,
      'activeAutomationRules': 6,
    });
    final user = PendingUser.fromJson({
      'id': 4,
      'email': 'pending@example.com',
      'role': 'EMPLOYEE',
      'status': 'PENDING',
    });
    final account = AdminAccount.fromJson({
      'id': 5,
      'accountNumber': '1000001234',
      'accountType': 'SAVINGS',
      'balance': 250.5,
      'status': 'ACTIVE',
      'customerName': 'Example',
    });
    final rule = AutomationRule.fromJson({
      'id': 6,
      'name': 'Rule',
      'type': 'INVALID_AMOUNT',
      'description': 'Description',
      'active': true,
    });
    final log = AuditLog.fromJson({
      'id': 7,
      'action': 'RULE_TRIGGERED',
      'ruleType': 'INVALID_AMOUNT',
      'description': 'Description',
      'result': 'SUCCESS',
      'createdAt': '2026-01-01T10:00:00',
      'user': null,
    });

    expect(overview.totalCustomers, 7);
    expect(user.role, 'EMPLOYEE');
    expect(account.balance, 250.5);
    expect(rule.active, isTrue);
    expect(log.createdAt, isNotNull);
  });
}
