import 'package:flutter/material.dart';

import '../../state/session_controller.dart';

class RoleHomeScreen extends StatelessWidget {
  const RoleHomeScreen({required this.session, super.key});

  final SessionController session;

  @override
  Widget build(BuildContext context) {
    final role = session.session?.role ?? 'USER';
    final roleLabel = role[0] + role.substring(1).toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('BankEase'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: session.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$roleLabel access confirmed',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    session.session?.email ?? '',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Authentication is connected. Customer, employee, and admin dashboards will be added in a later mobile phase.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: session.logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Log out'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
