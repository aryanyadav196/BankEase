class AdminOverview {
  const AdminOverview({
    required this.totalUsers,
    required this.totalCustomers,
    required this.totalAccounts,
    required this.totalTransactions,
    required this.pendingServiceRequests,
    required this.blockedAccounts,
    required this.rejectedTransactions,
    required this.totalAuditLogs,
    required this.activeAutomationRules,
  });

  final int totalUsers;
  final int totalCustomers;
  final int totalAccounts;
  final int totalTransactions;
  final int pendingServiceRequests;
  final int blockedAccounts;
  final int rejectedTransactions;
  final int totalAuditLogs;
  final int activeAutomationRules;

  factory AdminOverview.fromJson(Map<String, dynamic> json) => AdminOverview(
    totalUsers: _number(json['totalUsers']),
    totalCustomers: _number(json['totalCustomers']),
    totalAccounts: _number(json['totalAccounts']),
    totalTransactions: _number(json['totalTransactions']),
    pendingServiceRequests: _number(json['pendingServiceRequests']),
    blockedAccounts: _number(json['blockedAccounts']),
    rejectedTransactions: _number(json['rejectedTransactions']),
    totalAuditLogs: _number(json['totalAuditLogs']),
    activeAutomationRules: _number(json['activeAutomationRules']),
  );
}

int _number(dynamic value) => (value as num?)?.toInt() ?? 0;
