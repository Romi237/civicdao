import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset password'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _sent ? _sentView() : _formView(),
        ),
      ),
    );
  }

  Widget _formView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(color: AppColors.purple.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.lock_reset_rounded, color: AppColors.purple, size: 28),
        ),
        const SizedBox(height: 20),
        const Text("Forgot your password?", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text("Enter your email and we'll send you a reset link.", style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
        const SizedBox(height: 28),
        const Text('Email address', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'you@email.com', prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted, size: 20)),
        ),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Send reset link', onTap: () => setState(() => _sent = true)),
        const SizedBox(height: 16),
        Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text('Back to sign in', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _sentView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: const Icon(Icons.mark_email_read_outlined, color: AppColors.green, size: 40),
        ),
        const SizedBox(height: 24),
        const Text('Check your email', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text("We sent a reset link to ${_emailCtrl.text.isNotEmpty ? _emailCtrl.text : 'your email'}. Check your inbox and follow the instructions.", textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.6)),
        const SizedBox(height: 32),
        PrimaryButton(label: 'Back to sign in', onTap: () => Navigator.pop(context)),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () => setState(() => _sent = false),
          child: const Text("Didn't receive it? Resend", style: TextStyle(color: AppColors.purple, fontSize: 13)),
        ),
      ],
    );
  }
}


