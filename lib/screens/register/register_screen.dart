import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../enums/gender.dart';
import '../../models/user.dart';
import '../../validators/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../login/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Gender _selectedGender = Gender.male;

  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validate() {
    setState(() {
      _firstNameError = Validators.validateEmpty(_firstNameController.text,
          fieldName: 'First name');
      _lastNameError = Validators.validateEmpty(_lastNameController.text,
          fieldName: 'Last name');
      _emailError = Validators.validateEmail(_emailController.text);
      _passwordError = Validators.validatePassword(_passwordController.text);
      _confirmPasswordError = Validators.validateMatch(
        _confirmPasswordController.text,
        _passwordController.text,
        fieldName: 'Confirm password',
      );
    });
  }

  bool get _isFormValid {
    return _firstNameError == null &&
        _lastNameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;
  }

  // ── Now async, and properly awaits AuthController.register() ──
  Future<void> _submit() async {
    _validate();
    if (!_isFormValid) return;

    setState(() => _isSubmitting = true);

    final user = User(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      gender: _selectedGender,
      password: _passwordController.text,
    );

    await AuthController.instance.register(user);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      child: Icon(Icons.person_add_alt,
                          size: 30, color: colorScheme.onPrimaryContainer),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Create account',
                      style: textTheme.headlineSmall,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 6),
                  Text(
                    'Sign up to get started',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  CustomTextField(
                    controller: _firstNameController,
                    label: 'First name',
                    errorText: _firstNameError,
                    onChanged: (_) => _validate(),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _lastNameController,
                    label: 'Last name',
                    errorText: _lastNameError,
                    onChanged: (_) => _validate(),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    errorText: _emailError,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => _validate(),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<Gender>(
                    value: _selectedGender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: Gender.values
                        .map((g) =>
                            DropdownMenuItem(value: g, child: Text(g.label)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedGender = value);
                      }
                    },
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
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm password',
                    errorText: _confirmPasswordError,
                    obscureText: _obscureConfirmPassword,
                    onChanged: (_) => _validate(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () => setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  const SizedBox(height: 28),
                  CustomButton(
                    label: _isSubmitting ? 'Please wait…' : 'Register',
                    onPressed:
                        (_isFormValid && !_isSubmitting) ? _submit : null,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        );
                      },
                      child: const Text('Already have an account? Login'),
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
