import 'package:flutter/material.dart';

import '../../state/session_controller.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.session, super.key});

  final SessionController session;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'CUSTOMER';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.session.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      expectedRole: _role,
    );

    if (!mounted || success) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final busy = widget.session.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _BrandHeader(),
                        const SizedBox(height: 28),
                        Text(
                          'Welcome back',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        const Text('Sign in to your BankEase workspace.'),
                        const SizedBox(height: 24),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'CUSTOMER',
                              label: Text('Customer'),
                            ),
                            ButtonSegment(
                              value: 'EMPLOYEE',
                              label: Text('Employee'),
                            ),
                            ButtonSegment(value: 'ADMIN', label: Text('Admin')),
                          ],
                          selected: {_role},
                          onSelectionChanged: busy
                              ? null
                              : (selection) =>
                                    setState(() => _role = selection.first),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.username],
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty)
                              return 'Email is required.';
                            if (!value.contains('@'))
                              return 'Enter a valid email.';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Password is required.'
                              : null,
                        ),
                        if (widget.session.errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            widget.session.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 22),
                        FilledButton(
                          onPressed: busy ? null : _submit,
                          child: busy
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Sign in'),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: busy
                              ? null
                              : () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => RegistrationScreen(
                                      session: widget.session,
                                      initialRole: _role,
                                    ),
                                  ),
                                ),
                          child: const Text('Create or request an account'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Text(
            'B',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'BankEase',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
