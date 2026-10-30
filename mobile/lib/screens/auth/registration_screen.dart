import 'package:flutter/material.dart';

import '../../state/session_controller.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({
    required this.session,
    required this.initialRole,
    super.key,
  });

  final SessionController session;
  final String initialRole;

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  late String _role;
  String? _success;

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole;
  }

  @override
  void dispose() {
    for (final controller in [
      _fullName,
      _email,
      _phone,
      _address,
      _password,
      _confirmPassword,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_password.text != _confirmPassword.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
      return;
    }

    String? message;
    if (_role == 'CUSTOMER') {
      message = await widget.session.registerCustomer(
        fullName: _fullName.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        address: _address.text.trim(),
        password: _password.text,
      );
    } else {
      message = await widget.session.registerStaff(
        role: _role,
        email: _email.text.trim(),
        password: _password.text,
      );
    }

    if (!mounted) return;
    setState(() => _success = message);
  }

  @override
  Widget build(BuildContext context) {
    final busy = widget.session.isLoading;
    final customer = _role == 'CUSTOMER';

    return Scaffold(
      appBar: AppBar(title: const Text('BankEase registration')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Choose account type',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
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
                          : (selection) => setState(() {
                              _role = selection.first;
                              _success = null;
                            }),
                    ),
                    const SizedBox(height: 20),
                    if (customer) ...[
                      _field(_fullName, 'Full name'),
                      const SizedBox(height: 14),
                      _field(
                        _phone,
                        'Phone',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),
                      _field(_address, 'Address', required: false),
                      const SizedBox(height: 14),
                    ],
                    _field(
                      _email,
                      'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    _field(_password, 'Password', obscure: true, minLength: 8),
                    const SizedBox(height: 14),
                    _field(_confirmPassword, 'Confirm password', obscure: true),
                    if (widget.session.errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        widget.session.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    if (_success != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _success!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
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
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Submit registration'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Back to sign in'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = true,
    bool obscure = false,
    TextInputType? keyboardType,
    int? minLength,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty))
          return '$label is required.';
        if (minLength != null && (value?.length ?? 0) < minLength)
          return '$label must be at least $minLength characters.';
        if (label == 'Email' && value != null && !value.contains('@'))
          return 'Enter a valid email.';
        return null;
      },
    );
  }
}
