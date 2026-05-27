import 'package:flutter/material.dart';
import '../navigation/app_routes.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _walletConnected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create account'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Join your DAO — it takes 2 minutes.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 24),
              _label('Full name'),
              TextField(controller: _nameCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Alex Morgan')),
              const SizedBox(height: 14),
              _label('Email'),
              TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'you@email.com')),
              const SizedBox(height: 14),
              _label('Username'),
              TextField(controller: _userCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: '@handle')),
              const SizedBox(height: 14),
              _label('Password'),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Min. 8 characters',
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscure = !_obscure),
                    child: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textMuted, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Wallet card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.account_balance_wallet_outlined, color: AppColors.purple, size: 18),
                      SizedBox(width: 8),
                      Text('Connect wallet', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      SizedBox(width: 8),
                      StatusBadge('Optional'),
                    ]),
                    const SizedBox(height: 8),
                    const Text('Link a crypto wallet to sign votes on-chain and boost your credibility score.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5)),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => setState(() => _walletConnected = !_walletConnected),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: _walletConnected ? AppColors.green.withValues(alpha: 0.15) : AppColors.border.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _walletConnected ? AppColors.green.withValues(alpha: 0.4) : AppColors.border),
                        ),
                        child: Text(
                          _walletConnected ? '✓ MetaMask connected' : 'Connect MetaMask',
                          style: TextStyle(color: _walletConnected ? AppColors.green : AppColors.purple, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Create my account',
                onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.onboarding),
              ),
              const SizedBox(height: 14),
              Center(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    children: [
                      TextSpan(text: 'By signing up you agree to the '),
                      TextSpan(text: 'Terms of Service', style: TextStyle(color: AppColors.purple)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
  );
}


