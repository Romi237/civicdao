import 'package:flutter/material.dart';
import '../navigation/app_routes.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _proposals = [
    {'title': 'Fund Community Event', 'desc': 'Allocate 5,000 CIVIC for our annual community meetup and workshops.', 'status': 'Active', 'time': 'Ends in 2d 14h', 'for': 68, 'against': 21, 'abstain': 11},
    {'title': 'Update Governance Rules', 'desc': 'Propose changes to improve governance transparency.', 'status': 'Active', 'time': 'Ends in 5d 3h', 'for': 75, 'against': 15, 'abstain': 10},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Top bar
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Icon(Icons.menu_rounded, color: Colors.white70),
              const Text('CiviDao', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
                child: Stack(children: [
                  const Icon(Icons.notifications_outlined, color: Colors.white70, size: 26),
                  Positioned(right: 0, top: 0, child: Container(width: 9, height: 9, decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: AppColors.bg, width: 1.5))))),
                ]),
              ),
            ]),
            const SizedBox(height: 22),
            const Text('Hello, Alex 👋', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const Text('Together we govern better.', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Voting power card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF3730A3), AppColors.purple], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Your Voting Power', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  const Text('1,250 CIVIC', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('≈ \$562.50', style: TextStyle(color: Colors.white60, fontSize: 13)),
                ])),
                Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle), child: const Icon(Icons.toll_rounded, color: Colors.white, size: 30)),
              ]),
            ),
            const SizedBox(height: 20),

            // Quick actions
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _QuickAction(icon: Icons.article_outlined, label: 'Proposals', onTap: () {}),
              _QuickAction(icon: Icons.account_balance_wallet_outlined, label: 'Treasury', onTap: () {}),
              _QuickAction(icon: Icons.people_outline_rounded, label: 'Members', onTap: () => Navigator.pushNamed(context, AppRoutes.members)),
              _QuickAction(icon: Icons.bar_chart_rounded, label: 'Activity', onTap: () {}),
            ]),
            const SizedBox(height: 28),

            // Active proposals
            SectionHeader(title: 'Active Proposals', actionLabel: 'See all', onAction: () {}),
            const SizedBox(height: 14),
            ..._proposals.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                onTap: () => Navigator.pushNamed(context, AppRoutes.voteDetail, arguments: {'proposal': p}),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(child: Text(p['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
                    const SizedBox(width: 8),
                    StatusBadge(p['status'] as String),
                  ]),
                  const SizedBox(height: 6),
                  Text(p['desc'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4)),
                  const SizedBox(height: 8),
                  Text(p['time'] as String, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  const SizedBox(height: 8),
                  VoteProgressBar(forPct: p['for'] as int, againstPct: p['against'] as int, abstainPct: p['abstain'] as int),
                ]),
              ),
            )),
          ]),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(width: 56, height: 56, decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: AppColors.purple, size: 24)),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ]),
    );
  }
}

