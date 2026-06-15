import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    required this.onLogin,
    required this.onCreateAccount,
    this.isLoading = false,
    this.errorMessage,
    super.key,
  });

  final Future<void> Function({
    required String email,
    required String password,
    required String displayName,
  })
  onLogin;
  final Future<void> Function({
    required String email,
    required String password,
    required String displayName,
  })
  onCreateAccount;
  final bool isLoading;
  final String? errorMessage;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Huy Nguyen');
  final _emailController = TextEditingController(text: 'huy@example.com');
  final _passwordController = TextEditingController(text: 'demo123');
  bool _isCreatingAccount = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final action = _isCreatingAccount
        ? widget.onCreateAccount
        : widget.onLogin;
    await action(
        email: _emailController.text,
        password: _passwordController.text,
        displayName: _nameController.text,
      );
  }

  Future<void> _useFixedLocalAccount() async {
    setState(() {
      _isCreatingAccount = false;
      _nameController.text = 'Huy Nguyen';
      _emailController.text = 'huy@example.com';
      _passwordController.text = 'demo123';
    });
    await widget.onLogin(
      email: _emailController.text,
      password: _passwordController.text,
      displayName: _nameController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              _isCreatingAccount ? 'Create account' : 'Welcome back',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Use a local account to keep your daily state on this device.',
            ),
            const SizedBox(height: 8),
            const Text('Fixed local account: huy@example.com / demo123'),
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.login),
                  label: Text('Login'),
                ),
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.person_add_alt_1),
                  label: Text('Create'),
                ),
              ],
              selected: {_isCreatingAccount},
              onSelectionChanged: widget.isLoading
                  ? null
                  : (selection) {
                      setState(() {
                        _isCreatingAccount = selection.first;
                        if (_isCreatingAccount &&
                            _emailController.text == 'huy@example.com') {
                          _nameController.clear();
                          _emailController.clear();
                          _passwordController.clear();
                        }
                      });
                    },
            ),
            const SizedBox(height: 16),
            if (widget.errorMessage != null) ...[
              _StatusBanner(
                icon: Icons.error_outline,
                message: widget.errorMessage!,
                isError: true,
              ),
              const SizedBox(height: 12),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        key: const Key('loginNameField'),
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: _required,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('loginEmailField'),
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: _required,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('loginPasswordField'),
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          helperText: 'Local demo only, not production auth.',
                        ),
                        obscureText: true,
                        validator: _required,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          key: const Key('loginButton'),
                          onPressed: widget.isLoading ? null : _submit,
                          icon: widget.isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  _isCreatingAccount
                                      ? Icons.person_add_alt_1
                                      : Icons.login,
                                ),
                          label: Text(
                            _isCreatingAccount
                                ? 'Create local account'
                                : 'Login',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          key: const Key('useFixedLocalAccountButton'),
                          onPressed: widget.isLoading
                              ? null
                              : _useFixedLocalAccount,
                          icon: const Icon(Icons.bolt_outlined),
                          label: const Text('Use fixed local account'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.icon,
    required this.message,
    required this.isError,
  });

  final IconData icon;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isError ? colorScheme.error : colorScheme.primary;

    return Card(
      color: color.withValues(alpha: 0.08),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(message, style: TextStyle(color: color)),
      ),
    );
  }
}
