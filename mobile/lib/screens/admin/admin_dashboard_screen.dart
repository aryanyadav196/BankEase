import 'package:flutter/material.dart';

import '../../models/admin_account.dart';
import '../../models/admin_overview.dart';
import '../../models/audit_log.dart';
import '../../models/automation_rule.dart';
import '../../models/bank_transaction.dart';
import '../../models/pending_user.dart';
import '../../services/api_client.dart';
import '../../state/session_controller.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({required this.session, super.key});
  final SessionController session;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  bool _loading = true;
  String? _error;
  AdminOverview? _overview;
  List<PendingUser> _pendingUsers = [];
  List<AdminAccount> _accounts = [];
  List<BankTransaction> _transactions = [];
  List<AutomationRule> _rules = [];
  List<AuditLog> _logs = [];
  int? _busyUserId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool showLoading = true}) async {
    final session = widget.session.session;
    if (session == null || session.role != 'ADMIN') return;
    if (showLoading && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final result = await Future.wait<dynamic>([
        _adminRequest(
          '/admin/overview',
          () => widget.session.api.getAdminOverview(token: session.token),
        ),
        _adminRequest(
          '/admin/pending-users',
          () => widget.session.api.getPendingUsers(token: session.token),
        ),
        _adminRequest(
          '/admin/accounts',
          () => widget.session.api.getAdminAccounts(token: session.token),
        ),
        _adminRequest(
          '/admin/transactions',
          () => widget.session.api.getAdminTransactions(token: session.token),
        ),
        _adminRequest(
          '/admin/automation-rules',
          () => widget.session.api.getAutomationRules(token: session.token),
        ),
        _adminRequest(
          '/admin/audit-logs',
          () => widget.session.api.getAuditLogs(token: session.token),
        ),
      ]);
      if (!mounted) return;
      setState(() {
        _overview = AdminOverview.fromJson(result[0] as Map<String, dynamic>);
        _pendingUsers = (result[1] as List<Map<String, dynamic>>)
            .map(PendingUser.fromJson)
            .toList();
        _accounts = (result[2] as List<Map<String, dynamic>>)
            .map(AdminAccount.fromJson)
            .toList();
        _transactions = (result[3] as List<Map<String, dynamic>>)
            .map(BankTransaction.fromJson)
            .toList();
        _rules = (result[4] as List<Map<String, dynamic>>)
            .map(AutomationRule.fromJson)
            .toList();
        _logs = (result[5] as List<Map<String, dynamic>>)
            .map(AuditLog.fromJson)
            .toList();
        _loading = false;
        _error = null;
      });
    } on ApiException catch (error) {
      debugPrint(
        '[BankEase admin] ${error.endpoint ?? 'unknown endpoint'} '
        'HTTP ${error.statusCode ?? 'network'}: '
        '${error.safeResponse ?? error.message}',
      );
      if (error.isUnauthorized) await widget.session.handleUnauthorized();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.isUnauthorized
            ? 'Your admin session expired. Please sign in again.'
            : _adminErrorMessage(error);
      });
    } catch (error, stackTrace) {
      debugPrint(
        '[BankEase admin] unexpected dashboard failure '
        '${error.runtimeType}: $error',
      );
      debugPrint('$stackTrace');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error =
            'Unable to load the admin workspace '
            '(unexpected ${error.runtimeType}). Check the debug log.';
      });
    }
  }

  Future<T> _adminRequest<T>(
    String endpoint,
    Future<T> Function() operation,
  ) async {
    try {
      final result = await operation();
      debugPrint('[BankEase admin] GET $endpoint succeeded');
      return result;
    } on ApiException catch (error, stackTrace) {
      final detailed = error.endpoint == null
          ? ApiException(
              error.message,
              statusCode: error.statusCode,
              endpoint: endpoint,
              safeResponse: error.safeResponse,
            )
          : error;
      debugPrint(
        '[BankEase admin] GET ${detailed.endpoint} '
        'HTTP ${detailed.statusCode ?? 'network'}: '
        '${detailed.safeResponse ?? detailed.message}',
      );
      debugPrint('$stackTrace');
      throw detailed;
    } catch (error, stackTrace) {
      debugPrint(
        '[BankEase admin] GET $endpoint response/runtime failure '
        '${error.runtimeType}: $error',
      );
      debugPrint('$stackTrace');
      throw ApiException(
        'Admin response parsing failed.',
        endpoint: endpoint,
        safeResponse: error.runtimeType.toString(),
      );
    }
  }

  String _adminErrorMessage(ApiException error) {
    final endpoint = error.endpoint == null ? '' : ' (${error.endpoint})';
    final status = error.statusCode == null
        ? ''
        : ' [HTTP ${error.statusCode}]';
    final detail = error.safeResponse == null ? '' : ' ${error.safeResponse}';
    return '${error.message}$endpoint$status$detail';
  }

  Future<void> _pendingUserAction(PendingUser user, bool approve) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approve ? 'Approve registration?' : 'Remove registration?'),
        content: Text(
          approve
              ? 'Approve ${user.email} as ${_pretty(user.role)}?'
              : 'Remove the pending registration for ${user.email}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(approve ? 'Approve' : 'Remove'),
          ),
        ],
      ),
    );
    final session = widget.session.session;
    if (confirmed != true || session == null) return;
    setState(() => _busyUserId = user.id);
    try {
      final response = approve
          ? await widget.session.api.approvePendingUser(
              userId: user.id,
              token: session.token,
            )
          : await widget.session.api.removePendingUser(
              userId: user.id,
              token: session.token,
            );
      final message = response['message'] as String?;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message ??
                (approve ? 'Registration approved.' : 'Registration removed.'),
          ),
        ),
      );
      await _load(showLoading: false);
    } on ApiException catch (error) {
      if (error.isUnauthorized) await widget.session.handleUnauthorized();
      if (mounted) {
        _showError(
          error.isUnauthorized ? 'Your session expired.' : error.message,
        );
      }
    } finally {
      if (mounted) setState(() => _busyUserId = null);
    }
  }

  void _showError(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    if (widget.session.session?.role != 'ADMIN') {
      return const SizedBox.shrink();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: widget.session.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _ErrorState(message: _error!, onRetry: _load)
          : _page,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.how_to_reg_outlined),
            selectedIcon: Icon(Icons.how_to_reg),
            label: 'Pending',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance),
            label: 'Accounts',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.rule_outlined),
            selectedIcon: Icon(Icons.rule),
            label: 'Rules',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history_toggle_off),
            label: 'Audit',
          ),
        ],
      ),
    );
  }

  static const _titles = [
    'Overview',
    'Pending Users',
    'Accounts',
    'Transactions',
    'Automation Rules',
    'Audit Logs',
  ];

  Widget get _page => switch (_selectedIndex) {
    1 => _PendingPage(
      users: _pendingUsers,
      busyUserId: _busyUserId,
      onAction: _pendingUserAction,
    ),
    2 => _AccountsPage(accounts: _accounts),
    3 => _TransactionsPage(transactions: _transactions),
    4 => _RulesPage(rules: _rules),
    5 => _AuditPage(logs: _logs),
    _ => _OverviewPage(overview: _overview),
  };
}

class _OverviewPage extends StatelessWidget {
  const _OverviewPage({required this.overview});
  final AdminOverview? overview;
  @override
  Widget build(BuildContext context) {
    if (overview == null) {
      return const _EmptyState(
        icon: Icons.dashboard_outlined,
        message: 'No overview data was returned.',
      );
    }
    final cards = <(String, int, IconData)>[
      ('Users', overview!.totalUsers, Icons.people_outline),
      ('Customers', overview!.totalCustomers, Icons.person_outline),
      ('Accounts', overview!.totalAccounts, Icons.account_balance_outlined),
      (
        'Transactions',
        overview!.totalTransactions,
        Icons.receipt_long_outlined,
      ),
      (
        'Pending requests',
        overview!.pendingServiceRequests,
        Icons.support_agent_outlined,
      ),
      ('Blocked accounts', overview!.blockedAccounts, Icons.lock_outline),
      (
        'Rejected transactions',
        overview!.rejectedTransactions,
        Icons.cancel_outlined,
      ),
      ('Audit events', overview!.totalAuditLogs, Icons.history),
      ('Active rules', overview!.activeAutomationRules, Icons.rule_outlined),
    ];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'System control centre',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text('Live statistics returned by the BankEase admin API.'),
        const SizedBox(height: 18),
        ...cards.map(
          (card) => Card(
            child: ListTile(
              leading: Icon(card.$3),
              title: Text(card.$1),
              trailing: Text(
                '${card.$2}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PendingPage extends StatelessWidget {
  const _PendingPage({
    required this.users,
    required this.busyUserId,
    required this.onAction,
  });
  final List<PendingUser> users;
  final int? busyUserId;
  final Future<void> Function(PendingUser, bool) onAction;
  @override
  Widget build(BuildContext context) => _ListPage(
    title: 'Pending registrations',
    subtitle: 'Review staff registration requests returned by the server.',
    empty: 'No pending registrations.',
    isEmpty: users.isEmpty,
    children: users
        .map(
          (user) => Card(
            child: ListTile(
              leading: const Icon(Icons.person_add_outlined),
              title: Text(user.email),
              subtitle: Text('${_pretty(user.role)} • ${_pretty(user.status)}'),
              trailing: Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    tooltip: 'Approve',
                    onPressed: busyUserId == user.id
                        ? null
                        : () => onAction(user, true),
                    icon: busyUserId == user.id
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle_outline),
                  ),
                  IconButton(
                    tooltip: 'Remove',
                    onPressed: busyUserId == user.id
                        ? null
                        : () => onAction(user, false),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList(),
  );
}

class _AccountsPage extends StatelessWidget {
  const _AccountsPage({required this.accounts});
  final List<AdminAccount> accounts;
  @override
  Widget build(BuildContext context) => _ListPage(
    title: 'Accounts',
    subtitle: 'Read-only account records from the admin API.',
    empty: 'No accounts returned.',
    isEmpty: accounts.isEmpty,
    children: accounts
        .map(
          (account) => Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_outlined),
              title: Text(_mask(account.accountNumber)),
              subtitle: Text(
                '${account.customerName ?? 'Customer unavailable'} • ${_pretty(account.accountType)} • ${_pretty(account.status)}',
              ),
              trailing: Text(_money(account.balance)),
            ),
          ),
        )
        .toList(),
  );
}

class _TransactionsPage extends StatelessWidget {
  const _TransactionsPage({required this.transactions});
  final List<BankTransaction> transactions;
  @override
  Widget build(BuildContext context) => _ListPage(
    title: 'Transactions',
    subtitle:
        'Read-only transaction records. No money-moving actions are exposed.',
    empty: 'No transactions returned.',
    isEmpty: transactions.isEmpty,
    children: transactions
        .map(
          (transaction) => Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: Text(
                '${_pretty(transaction.type)} • ${_money(transaction.amount)}',
              ),
              subtitle: Text(
                '${_pretty(transaction.status)} • ${transaction.reference}\n${_date(transaction.createdAt)}',
              ),
              isThreeLine: true,
            ),
          ),
        )
        .toList(),
  );
}

class _RulesPage extends StatelessWidget {
  const _RulesPage({required this.rules});
  final List<AutomationRule> rules;
  @override
  Widget build(BuildContext context) => _ListPage(
    title: 'Automation rules',
    subtitle: 'Read-only rules configured by the backend.',
    empty: 'No automation rules returned.',
    isEmpty: rules.isEmpty,
    children: rules
        .map(
          (rule) => Card(
            child: ListTile(
              leading: Icon(rule.active ? Icons.toggle_on : Icons.toggle_off),
              title: Text(rule.name.isEmpty ? _pretty(rule.type) : rule.name),
              subtitle: Text('${_pretty(rule.type)}\n${rule.description}'),
              isThreeLine: true,
              trailing: Text(rule.active ? 'Active' : 'Inactive'),
            ),
          ),
        )
        .toList(),
  );
}

class _AuditPage extends StatelessWidget {
  const _AuditPage({required this.logs});
  final List<AuditLog> logs;
  @override
  Widget build(BuildContext context) => _ListPage(
    title: 'Audit logs',
    subtitle: 'Recorded actions and automation outcomes.',
    empty: 'No audit logs returned.',
    isEmpty: logs.isEmpty,
    children: logs
        .map(
          (log) => Card(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: Text(_pretty(log.action)),
              subtitle: Text(
                '${_pretty(log.result)} • ${log.ruleType == null ? 'Rule type unavailable' : _pretty(log.ruleType!)}\n${log.description}\n${_date(log.createdAt)}',
              ),
              isThreeLine: true,
              trailing: log.user == null
                  ? null
                  : Text(log.user!, overflow: TextOverflow.ellipsis),
            ),
          ),
        )
        .toList(),
  );
}

class _ListPage extends StatelessWidget {
  const _ListPage({
    required this.title,
    required this.subtitle,
    required this.empty,
    required this.isEmpty,
    required this.children,
  });
  final String title;
  final String subtitle;
  final String empty;
  final bool isEmpty;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 6),
      Text(subtitle),
      const SizedBox(height: 16),
      if (isEmpty)
        _EmptyState(message: empty, icon: Icons.inbox_outlined)
      else
        ...children,
    ],
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(30),
    child: Column(
      children: [
        Icon(icon, size: 44),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
      ],
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 48),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}

String _pretty(String value) => value
    .toLowerCase()
    .split('_')
    .map(
      (part) =>
          part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}',
    )
    .join(' ');
String _mask(String value) =>
    value.length <= 4 ? value : '•••• ${value.substring(value.length - 4)}';
String _money(double value) => '₹${value.toStringAsFixed(2)}';
String _date(DateTime? value) =>
    value == null ? 'Timestamp unavailable' : value.toLocal().toString();
