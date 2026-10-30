import 'package:flutter/material.dart';

import '../../models/account.dart';
import '../../models/bank_transaction.dart';
import '../../models/customer_profile.dart';
import '../../models/service_request.dart';
import '../../services/api_client.dart';
import '../../services/bankease_api.dart';
import '../../state/session_controller.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({required this.session, super.key});
  final SessionController session;

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  CustomerProfile? _profile;
  List<BankAccount> _accounts = [];
  List<BankTransaction> _transactions = [];
  List<CustomerServiceRequest> _requests = [];
  int _selectedIndex = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    final session = widget.session.session;
    if (session == null) return;

    try {
      final profile = CustomerProfile.fromJson(
        await widget.session.api.getMyProfile(token: session.token),
      );
      final results = await Future.wait([
        widget.session.api.getMyAccounts(
          customerId: profile.id,
          token: session.token,
        ),
        widget.session.api.getMyTransactions(token: session.token),
        widget.session.api.getMyServiceRequests(
          customerId: profile.id,
          token: session.token,
        ),
      ]);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _accounts = results[0].map(BankAccount.fromJson).toList();
        _transactions = results[1].map(BankTransaction.fromJson).toList();
        _requests = results[2].map(CustomerServiceRequest.fromJson).toList();
        _loading = false;
        _error = null;
      });
    } on ApiException catch (error) {
      if (error.isUnauthorized) await widget.session.handleUnauthorized();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.isUnauthorized
            ? 'Your session expired. Please sign in again.'
            : error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Unable to load your BankEase dashboard.';
      });
    }
  }

  Future<void> _openCreateRequest() async {
    final profile = _profile;
    final session = widget.session.session;
    if (profile == null || session == null) return;
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => CreateServiceRequestDialog(
        api: widget.session.api,
        customerId: profile.id,
        token: session.token,
        onUnauthorized: widget.session.handleUnauthorized,
      ),
    );
    if (created == true) await _loadDashboard(showLoading: false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loading && widget.session.session == null) {
      return const SizedBox.shrink();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadDashboard,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Log out',
            onPressed: widget.session.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _ErrorState(message: _error!, onRetry: _loadDashboard)
          : _page,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
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
            icon: Icon(Icons.support_agent_outlined),
            selectedIcon: Icon(Icons.support_agent),
            label: 'Requests',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  static const _titles = [
    'Home',
    'Accounts',
    'Transactions',
    'Service Requests',
    'Profile',
  ];

  Widget get _page {
    switch (_selectedIndex) {
      case 1:
        return _AccountsPage(accounts: _accounts);
      case 2:
        return _TransactionsPage(transactions: _transactions);
      case 3:
        return _RequestsPage(requests: _requests, onCreate: _openCreateRequest);
      case 4:
        return _ProfilePage(
          profile: _profile!,
          onLogout: widget.session.logout,
        );
      default:
        return _HomePage(
          profile: _profile!,
          accounts: _accounts,
          transactions: _transactions,
          requests: _requests,
          onAccounts: () => setState(() => _selectedIndex = 1),
          onTransactions: () => setState(() => _selectedIndex = 2),
          onRequests: () => setState(() => _selectedIndex = 3),
        );
    }
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({
    required this.profile,
    required this.accounts,
    required this.transactions,
    required this.requests,
    required this.onAccounts,
    required this.onTransactions,
    required this.onRequests,
  });
  final CustomerProfile profile;
  final List<BankAccount> accounts;
  final List<BankTransaction> transactions;
  final List<CustomerServiceRequest> requests;
  final VoidCallback onAccounts;
  final VoidCallback onTransactions;
  final VoidCallback onRequests;

  @override
  Widget build(BuildContext context) {
    final total = accounts.fold<double>(
      0,
      (sum, account) => sum + account.balance,
    );
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Welcome back, ${_firstName(profile.fullName)}',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text('Here is your banking overview.'),
        const SizedBox(height: 20),
        Card(
          color: Theme.of(context).colorScheme.primary,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total across accounts',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  _money(total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${accounts.length} account${accounts.length == 1 ? '' : 's'}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        _SectionHeading(
          title: 'Your accounts',
          action: 'View all',
          onTap: onAccounts,
        ),
        if (accounts.isEmpty)
          const _EmptyState(
            icon: Icons.account_balance_outlined,
            message: 'No accounts are available yet.',
          )
        else
          ...accounts.take(2).map((account) => _AccountCard(account: account)),
        const SizedBox(height: 14),
        _SectionHeading(
          title: 'Recent transactions',
          action: 'View all',
          onTap: onTransactions,
        ),
        if (transactions.isEmpty)
          const _EmptyState(
            icon: Icons.receipt_long_outlined,
            message: 'No transactions yet.',
          )
        else
          ...transactions
              .take(3)
              .map((transaction) => _TransactionTile(transaction: transaction)),
        const SizedBox(height: 14),
        _SectionHeading(
          title: 'Service requests',
          action: 'View all',
          onTap: onRequests,
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.support_agent),
            title: Text(
              '${requests.length} request${requests.length == 1 ? '' : 's'}',
            ),
            subtitle: Text(
              requests.isEmpty
                  ? 'No requests submitted.'
                  : '${requests.where((request) => request.status == 'PENDING').length} pending',
            ),
            onTap: onRequests,
          ),
        ),
      ],
    );
  }
}

class _AccountsPage extends StatelessWidget {
  const _AccountsPage({required this.accounts});
  final List<BankAccount> accounts;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      if (accounts.isEmpty)
        const _EmptyState(
          icon: Icons.account_balance_outlined,
          message: 'No accounts are available yet.',
        )
      else
        ...accounts.map(
          (account) => _AccountCard(account: account, expanded: true),
        ),
    ],
  );
}

class _TransactionsPage extends StatelessWidget {
  const _TransactionsPage({required this.transactions});
  final List<BankTransaction> transactions;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      if (transactions.isEmpty)
        const _EmptyState(
          icon: Icons.receipt_long_outlined,
          message: 'No transactions yet.',
        )
      else
        ...transactions.map(
          (transaction) => _TransactionTile(transaction: transaction),
        ),
    ],
  );
}

class _RequestsPage extends StatelessWidget {
  const _RequestsPage({required this.requests, required this.onCreate});
  final List<CustomerServiceRequest> requests;
  final VoidCallback onCreate;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Align(
        alignment: Alignment.centerRight,
        child: FilledButton.icon(
          onPressed: onCreate,
          icon: const Icon(Icons.add),
          label: const Text('New request'),
        ),
      ),
      const SizedBox(height: 12),
      if (requests.isEmpty)
        const _EmptyState(
          icon: Icons.support_agent_outlined,
          message: 'No service requests yet.',
        )
      else
        ...requests.map(
          (request) => Card(
            child: ListTile(
              isThreeLine: true,
              leading: const Icon(Icons.support_agent),
              title: Text(_pretty(request.type)),
              subtitle: Text(
                '${request.description}\n${_pretty(request.status)} · ${_pretty(request.priority)} · ${_date(request.createdAt)}',
              ),
              trailing: _StatusChip(request.status),
            ),
          ),
        ),
    ],
  );
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({required this.profile, required this.onLogout});
  final CustomerProfile profile;
  final VoidCallback onLogout;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      CircleAvatar(
        radius: 38,
        child: Text(
          profile.fullName.isEmpty ? '?' : profile.fullName[0].toUpperCase(),
          style: const TextStyle(fontSize: 28),
        ),
      ),
      const SizedBox(height: 14),
      Center(
        child: Text(
          profile.fullName,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      const SizedBox(height: 24),
      Card(
        child: Column(
          children: [
            _ProfileRow(label: 'Email', value: profile.email),
            _ProfileRow(label: 'Phone', value: profile.phone),
            _ProfileRow(
              label: 'Address',
              value: profile.address ?? 'Not provided',
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      OutlinedButton.icon(
        onPressed: onLogout,
        icon: const Icon(Icons.logout),
        label: const Text('Log out'),
      ),
    ],
  );
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account, this.expanded = false});
  final BankAccount account;
  final bool expanded;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _pretty(account.accountType),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              _StatusChip(account.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _mask(account.accountNumber),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            _money(account.balance),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (expanded) const SizedBox(height: 3),
          if (expanded)
            Text(
              'Account number is masked for privacy.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    ),
  );
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});
  final BankTransaction transaction;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: CircleAvatar(
        child: Icon(
          transaction.type == 'DEPOSIT'
              ? Icons.arrow_downward
              : Icons.arrow_upward,
        ),
      ),
      title: Text(_pretty(transaction.type)),
      subtitle: Text(
        '${transaction.description?.isNotEmpty == true ? transaction.description : transaction.reference}\n${_date(transaction.createdAt)}',
      ),
      isThreeLine: true,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _money(transaction.amount),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          _StatusChip(transaction.status),
        ],
      ),
    ),
  );
}

class CreateServiceRequestDialog extends StatefulWidget {
  const CreateServiceRequestDialog({
    required this.api,
    required this.customerId,
    required this.token,
    required this.onUnauthorized,
    super.key,
  });
  final BankEaseApi api;
  final int customerId;
  final String token;
  final Future<void> Function() onUnauthorized;
  @override
  State<CreateServiceRequestDialog> createState() =>
      _CreateServiceRequestDialogState();
}

class _CreateServiceRequestDialogState
    extends State<CreateServiceRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  String _type = 'GENERAL_QUERY';
  bool _saving = false;
  String? _error;
  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.api.createServiceRequest(
        customerId: widget.customerId,
        type: _type,
        description: _description.text.trim(),
        token: widget.token,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        await widget.onUnauthorized();
        return;
      }
      if (mounted) {
        setState(() {
          _saving = false;
          _error = error.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('New service request'),
    content: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _type,
            decoration: const InputDecoration(labelText: 'Request type'),
            items:
                const [
                      'GENERAL_QUERY',
                      'ACCOUNT_ISSUE',
                      'TRANSACTION_ISSUE',
                      'ACCOUNT_BLOCK_REQUEST',
                    ]
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(_pretty(type)),
                      ),
                    )
                    .toList(),
            onChanged: _saving
                ? null
                : (value) => setState(() => _type = value ?? _type),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _description,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Description'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Description is required.'
                : null,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _saving ? null : _submit,
        child: _saving
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Submit'),
      ),
    ],
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.action,
    required this.onTap,
  });
  final String title;
  final String action;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      TextButton(onPressed: onTap, child: Text(action)),
    ],
  );
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(label, style: Theme.of(context).textTheme.labelMedium),
    subtitle: Text(value),
  );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.status);
  final String status;
  @override
  Widget build(BuildContext context) =>
      Chip(label: Text(_pretty(status), style: const TextStyle(fontSize: 11)));
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
        Icon(icon, size: 42, color: Theme.of(context).colorScheme.outline),
        const SizedBox(height: 10),
        Text(message, textAlign: TextAlign.center),
      ],
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
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
String _firstName(String value) => value.trim().split(' ').first;
String _money(double value) => '₹${value.toStringAsFixed(2)}';
String _mask(String value) =>
    value.length <= 4 ? value : '•••• ${value.substring(value.length - 4)}';
String _date(DateTime? value) => value == null
    ? 'Date unavailable'
    : '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
