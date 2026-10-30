import 'package:flutter/material.dart';

import '../../models/employee_customer.dart';
import '../../models/employee_service_request.dart';
import '../../services/api_client.dart';
import '../../state/session_controller.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({required this.session, super.key});
  final SessionController session;

  @override
  State<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  int _selectedIndex = 0;
  bool _loading = true;
  String? _error;
  List<EmployeeCustomer> _customers = [];
  List<EmployeeServiceRequest> _requests = [];
  int? _busyRequestId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool showLoading = true}) async {
    final session = widget.session.session;
    if (session == null || session.role != 'EMPLOYEE') return;
    if (showLoading && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final results = await Future.wait([
        widget.session.api.getEmployeeCustomers(token: session.token),
        widget.session.api.getAllServiceRequests(token: session.token),
      ]);
      if (!mounted) return;
      setState(() {
        _customers = results[0].map(EmployeeCustomer.fromJson).toList();
        _requests = results[1].map(EmployeeServiceRequest.fromJson).toList();
        _loading = false;
        _error = null;
      });
    } on ApiException catch (error) {
      if (error.isUnauthorized) await widget.session.handleUnauthorized();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.isUnauthorized
            ? 'Your employee session expired. Please sign in again.'
            : error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Unable to load the employee workspace.';
      });
    }
  }

  Future<void> _createAccount(EmployeeCustomer customer) async {
    final type = await showDialog<String>(
      context: context,
      builder: (_) => _AccountTypeDialog(customerName: customer.fullName),
    );
    final session = widget.session.session;
    if (type == null || session == null) return;
    try {
      await widget.session.api.createAccount(
        customerId: customer.id,
        accountType: type,
        token: session.token,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully.')),
      );
      await _load(showLoading: false);
    } on ApiException catch (error) {
      if (error.isUnauthorized) await widget.session.handleUnauthorized();
      if (!mounted) return;
      _showError(
        error.isUnauthorized ? 'Your session expired.' : error.message,
      );
    }
  }

  Future<void> _changeRequestStatus(
    EmployeeServiceRequest request,
    String action,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action request?'),
        content: Text('This will update request #${request.id}. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    );
    final session = widget.session.session;
    if (confirmed != true || session == null) return;
    setState(() => _busyRequestId = request.id);
    try {
      final id = request.id;
      if (action == 'Start') {
        await widget.session.api.startServiceRequest(
          requestId: id,
          token: session.token,
        );
      } else if (action == 'Resolve') {
        await widget.session.api.resolveServiceRequest(
          requestId: id,
          token: session.token,
        );
      } else {
        await widget.session.api.rejectServiceRequest(
          requestId: id,
          token: session.token,
        );
      }
      await _load(showLoading: false);
    } on ApiException catch (error) {
      if (error.isUnauthorized) await widget.session.handleUnauthorized();
      if (mounted) {
        _showError(
          error.isUnauthorized ? 'Your session expired.' : error.message,
        );
      }
    } finally {
      if (mounted) setState(() => _busyRequestId = null);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.session.session?.role != 'EMPLOYEE') {
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
          : _selectedIndex == 0
          ? _CustomersPage(
              customers: _customers,
              onCreateAccount: _createAccount,
            )
          : _selectedIndex == 1
          ? _RequestsPage(
              requests: _requests,
              busyRequestId: _busyRequestId,
              onAction: _changeRequestStatus,
            )
          : _ProfilePage(session: widget.session),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Customers',
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

  static const _titles = ['Customers', 'Service Requests', 'Profile'];
}

class _CustomersPage extends StatelessWidget {
  const _CustomersPage({
    required this.customers,
    required this.onCreateAccount,
  });
  final List<EmployeeCustomer> customers;
  final Future<void> Function(EmployeeCustomer) onCreateAccount;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'Customer management',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 6),
      Text(
        '${customers.length} customer${customers.length == 1 ? '' : 's'} available.',
      ),
      const SizedBox(height: 16),
      if (customers.isEmpty)
        const _EmptyState(
          message: 'No customers were returned by the server.',
          icon: Icons.people_outline,
        )
      else
        ...customers.map(
          (customer) => Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(_initial(customer.fullName))),
              title: Text(
                customer.fullName.isEmpty
                    ? 'Unnamed customer'
                    : customer.fullName,
              ),
              subtitle: Text('${customer.email}\n${customer.phone}'),
              isThreeLine: true,
              trailing: IconButton(
                tooltip: 'Create account',
                icon: const Icon(Icons.add_card),
                onPressed: () => onCreateAccount(customer),
              ),
            ),
          ),
        ),
    ],
  );
}

class _RequestsPage extends StatelessWidget {
  const _RequestsPage({
    required this.requests,
    required this.busyRequestId,
    required this.onAction,
  });
  final List<EmployeeServiceRequest> requests;
  final int? busyRequestId;
  final Future<void> Function(EmployeeServiceRequest, String) onAction;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'Service requests',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 6),
      const Text('Process requests using the server-enforced workflow.'),
      const SizedBox(height: 16),
      if (requests.isEmpty)
        const _EmptyState(
          message: 'No service requests were returned by the server.',
          icon: Icons.support_agent_outlined,
        )
      else
        ...requests.map(
          (request) => _RequestCard(
            request: request,
            busy: busyRequestId == request.id,
            onAction: onAction,
          ),
        ),
    ],
  );
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.busy,
    required this.onAction,
  });
  final EmployeeServiceRequest request;
  final bool busy;
  final Future<void> Function(EmployeeServiceRequest, String) onAction;

  @override
  Widget build(BuildContext context) {
    final actions = request.status == 'PENDING'
        ? ['Start']
        : request.status == 'IN_PROGRESS'
        ? ['Resolve', 'Reject']
        : <String>[];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.customerName ?? 'Customer unavailable',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(label: Text(_pretty(request.status))),
              ],
            ),
            const SizedBox(height: 6),
            Text('${_pretty(request.type)} • ${_pretty(request.priority)}'),
            if (request.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(request.description),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: actions
                    .map(
                      (action) => FilledButton.tonal(
                        onPressed: busy
                            ? null
                            : () => onAction(request, action),
                        child: busy
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(action),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({required this.session});
  final SessionController session;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 32,
            child: Icon(Icons.badge_outlined, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            session.session?.email ?? 'Employee',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(session.session?.role ?? 'EMPLOYEE'),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: session.logout,
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
        ],
      ),
    ),
  );
}

class _AccountTypeDialog extends StatefulWidget {
  const _AccountTypeDialog({required this.customerName});
  final String customerName;
  @override
  State<_AccountTypeDialog> createState() => _AccountTypeDialogState();
}

class _AccountTypeDialogState extends State<_AccountTypeDialog> {
  String _type = 'SAVINGS';
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Create account'),
    content: DropdownButtonFormField<String>(
      value: _type,
      decoration: InputDecoration(
        labelText: 'Account type for ${widget.customerName}',
      ),
      items: const [
        DropdownMenuItem(value: 'SAVINGS', child: Text('Savings')),
        DropdownMenuItem(value: 'CURRENT', child: Text('Current')),
      ],
      onChanged: (value) => setState(() => _type = value ?? 'SAVINGS'),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _type),
        child: const Text('Create'),
      ),
    ],
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.icon});
  final String message;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(28),
    child: Column(
      children: [
        Icon(icon, size: 44),
        const SizedBox(height: 10),
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
String _initial(String value) =>
    value.trim().isEmpty ? '?' : value.trim()[0].toUpperCase();
