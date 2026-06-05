import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../navigation/app_routes.dart';
import '../services/auth_service.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = '';
    });

    final result = await Provider.of<AuthService>(
      context,
      listen: false,
    ).register(_emailCtrl.text.trim(), _passCtrl.text, _nameCtrl.text.trim());

    if (!mounted) {
      return;
    }
    setState(() => _loading = false);

    if (result['success'] == true) {
      Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
    } else {
      setState(() => _error = result['error'] ?? 'Registration failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Join CivicDAO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Create your account to start voting on proposals.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 28),
                if (_error.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _error,
                      style: const TextStyle(
                        color: AppColors.red,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
                TextFormField(
                  controller: _nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Name is required';
                    }
                    if (v.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Full name',
                    prefixIcon: Icon(
                      Icons.person_outlined,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Email address',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  style: const TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Password is required';
                    }
                    if (v.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => _obscure = !_obscure),
                      child: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _register(),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (v != _passCtrl.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Confirm password',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.purple,
                        ),
                      )
                    : PrimaryButton(label: 'Create account', onTap: _register),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Already have an account? Sign in',
                      style: TextStyle(color: AppColors.purple, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
