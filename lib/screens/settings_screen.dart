import 'package:flutter/material.dart';
import '../navigation/app_routes.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _voteReminders = true;
  bool _newProposals = true;
  bool _treasury = false;
  bool _members = false;
  bool _twoFA = true;
  String _visibility = 'Public';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _sectionLabel('Account'),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Column(children: [
              _SettingsRow(icon: Icons.person_outline_rounded, label: 'Edit profile', onTap: () {}),
              const Divider(color: AppColors.border, height: 1),
              _SettingsRow(icon: Icons.account_balance_wallet_outlined, label: 'Wallet address', trailing: const Text('0x4f8a...7e9d', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontFamily: 'monospace')), onTap: () {}),
              const Divider(color: AppColors.border, height: 1),
              _SettingsRow(icon: Icons.lock_outline_rounded, label: 'Change password', onTap: () {}),
            ]),
          ),
          const SizedBox(height: 20),
          _sectionLabel('Notifications'),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Column(children: [
              _ToggleRow(label: 'Vote reminders', value: _voteReminders, onChanged: (v) => setState(() => _voteReminders = v)),
              const Divider(color: AppColors.border, height: 1),
              _ToggleRow(label: 'New proposals', value: _newProposals, onChanged: (v) => setState(() => _newProposals = v)),
              const Divider(color: AppColors.border, height: 1),
              _ToggleRow(label: 'Treasury activity', value: _treasury, onChanged: (v) => setState(() => _treasury = v)),
              const Divider(color: AppColors.border, height: 1),
              _ToggleRow(label: 'Member updates', value: _members, onChanged: (v) => setState(() => _members = v)),
            ]),
          ),
          const SizedBox(height: 20),
          _sectionLabel('Governance'),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Column(children: [
              _SettingsRow(icon: Icons.share_outlined, label: 'Voting delegation', trailing: const Text('None', style: TextStyle(color: AppColors.textMuted, fontSize: 12)), onTap: () {}),
              const Divider(color: AppColors.border, height: 1),
              _SettingsRow(
                icon: Icons.visibility_outlined,
                label: 'Default vote visibility',
                trailing: Text(_visibility, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                onTap: () => setState(() => _visibility = _visibility == 'Public' ? 'Private' : 'Public'),
              ),
              const Divider(color: AppColors.border, height: 1),
              _ToggleRow(label: '2FA on votes', value: _twoFA, onChanged: (v) => setState(() => _twoFA = v)),
            ]),
          ),
          const SizedBox(height: 20),
          _sectionLabel('About'),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Column(children: [
              _SettingsRow(icon: Icons.info_outline_rounded, label: 'App version', trailing: const Text('v1.0.0', style: TextStyle(color: AppColors.textMuted, fontSize: 12)), onTap: () {}),
              const Divider(color: AppColors.border, height: 1),
              _SettingsRow(icon: Icons.description_outlined, label: 'Terms of Service', onTap: () {}),
              const Divider(color: AppColors.border, height: 1),
              _SettingsRow(icon: Icons.shield_outlined, label: 'Privacy Policy', onTap: () {}),
            ]),
          ),
          const SizedBox(height: 20),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: _SettingsRow(
              icon: Icons.logout_rounded,
              label: 'Sign out',
              iconColor: AppColors.red,
              labelColor: AppColors.red,
              onTap: () => showDialog(context: context, builder: (_) => AlertDialog(
                backgroundColor: AppColors.card,
                title: const Text('Sign out', style: TextStyle(color: Colors.white)),
                content: const Text('Are you sure you want to sign out?', style: TextStyle(color: AppColors.textSecondary)),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
                  TextButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false), child: const Text('Sign out', style: TextStyle(color: AppColors.red))),
                ],
              )),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _sectionLabel(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t.toUpperCase(), style: const TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 0.06, fontWeight: FontWeight.w500)),
  );
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? iconColor, labelColor;
  const _SettingsRow({required this.icon, required this.label, required this.onTap, this.trailing, this.iconColor, this.labelColor});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Row(children: [
      Icon(icon, color: iconColor ?? AppColors.textSecondary, size: 18),
      const SizedBox(width: 12),
      Expanded(child: Text(label, style: TextStyle(color: labelColor ?? Colors.white.withOpacity(0.85), fontSize: 14))),
      if (trailing != null) ...[trailing!, const SizedBox(width: 4)],
      Icon(Icons.chevron_right, color: AppColors.textMuted, size: 16),
    ])),
  );
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Row(children: [
    Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14))),
    AppToggle(value: value, onChanged: onChanged),
  ]));
}

