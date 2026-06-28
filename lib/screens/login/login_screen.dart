import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../validators/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../dashboard/dashboard_screen.dart';
import '../register/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _loginError;

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isCheckingSession = true;

  @override
  void initState() {
    super.initState();
    _checkRememberedSession();
  }

  Future<void> _checkRememberedSession() async {
    final user = await AuthController.instance.tryAutoLogin();
    if (!mounted) return;

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DashboardScreen(user: user)),
      );
      return;
    }

    setState(() => _isCheckingSession = false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validate() {
    setState(() {
      _emailError = Validators.validateEmail(_emailController.text);
      _passwordError = Validators.validateEmpty(_passwordController.text,
          fieldName: 'Password');
      _loginError = null;
    });
  }

  bool get _isFormValid {
    return _emailError == null &&
        _passwordError == null &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  Future<void> _submit() async {
    _validate();
    if (!_isFormValid) return;

    final user = await AuthController.instance.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (user == null) {
      setState(() => _loginError = 'Invalid email or password');
      return;
    }

    await AuthController.instance.setRememberMe(_rememberMe, user);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => DashboardScreen(user: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSession) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(Icons.lock_outline,
                          size: 30, color: colorScheme.onPrimaryContainer),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Welcome back',
                      style: textTheme.headlineSmall,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 6),
                  Text(
                    'Log in to continue',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    errorText: _emailError,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => _validate(),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    errorText: _passwordError,
                    obscureText: _obscurePassword,
                    onChanged: (_) => _validate(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  if (_loginError != null) ...[
                    const SizedBox(height: 10),
                    Text(_loginError!,
                        style: TextStyle(color: colorScheme.error)),
                  ],
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) =>
                            setState(() => _rememberMe = value ?? false),
                      ),
                      const Text('Remember Me'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CustomButton(
                    label: 'Login',
                    onPressed: _isFormValid ? _submit : null,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: const Text("Don't have an account? Register"),
                    ),
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
