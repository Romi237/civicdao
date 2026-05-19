import 'package:flutter/material.dart';
import 'dart:math';
import '../navigation/app_routes.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: const Padding(padding: EdgeInsets.only(left: 16), child: Icon(Icons.menu_rounded, color: Colors.white70)),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.white70), onPressed: () => Navigator.pushNamed(context, AppRoutes.settings)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [
          // Header
          Center(child: Column(children: [
            Container(
              width: 76, height: 76,
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF3730A3), AppColors.purple]), shape: BoxShape.circle),
              child: const Center(child: Text('AM', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(height: 12),
            const Text('Alex Morgan', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('0x4f8a...7e9d', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontFamily: 'monospace')),
            const SizedBox(height: 3),
            const Text('Joined March 12, 2024', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 10),
            const StatusBadge('Council'),
          ])),
          const SizedBox(height: 22),
          // Stats
          AppCard(
            padding: EdgeInsets.zero,
            child: Row(children: [
              Expanded(child: _StatCell(value: '1,250', label: 'Voting Power')),
              Container(width: 1, height: 40, color: AppColors.border),
              Expanded(child: _StatCell(value: '12', label: 'Proposals Voted')),
              Container(width: 1, height: 40, color: AppColors.border),
              Expanded(child: _StatCell(value: '85%', label: 'Participation')),
            ]),
          ),
          const SizedBox(height: 22),
          // Participation score
          const SectionHeader(title: 'Participation Score'),
          const SizedBox(height: 14),
          AppCard(
            child: Row(children: [
              SizedBox(width: 82, height: 82, child: CustomPaint(painter: _RingPainter(0.85), child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('85', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text('Great!', style: TextStyle(color: AppColors.green, fontSize: 9)),
              ])))),
              const SizedBox(width: 18),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("You're an active member of the governance. Keep it up!", style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5)),
                const SizedBox(height: 10),
                ...[
                  'Votes cast', 'On-time votes', 'Consistent activity'
                ].map((t) => Padding(padding: const EdgeInsets.only(bottom: 5), child: Row(children: [
                  Container(width: 16, height: 16, decoration: BoxDecoration(color: AppColors.green.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.check, color: AppColors.green, size: 10)),
                  const SizedBox(width: 6),
                  Text(t, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ]))),
              ])),
            ]),
          ),
          const SizedBox(height: 22),
          // Delegate button
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.delegate),
            child: AppCard(
              child: Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.purple.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.share_outlined, color: AppColors.purple, size: 20)),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Delegate your votes', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  Text('Let a trusted member vote on your behalf', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ])),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ]),
            ),
          ),
          const SizedBox(height: 22),
          // Activity
          SectionHeader(title: 'Activity', actionLabel: 'See all', onAction: () {}),
          const SizedBox(height: 14),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Column(children: [
              _ActivityRow(icon: Icons.check_rounded, color: AppColors.green, title: 'Voted For', sub: 'Fund Community Event', time: '2h ago'),
              const Divider(color: AppColors.border, height: 1),
              _ActivityRow(icon: Icons.add_rounded, color: AppColors.purple, title: 'Submitted Proposal', sub: 'Update Governance Rules', time: '3d ago'),
              const Divider(color: AppColors.border, height: 1),
              _ActivityRow(icon: Icons.close_rounded, color: AppColors.red, title: 'Voted Against', sub: 'New Grant Program', time: '5d ago'),
            ]),
          ),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value, label;
  const _StatCell({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Column(children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11), textAlign: TextAlign.center),
    ]),
  );
}

class _ActivityRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, sub, time;
  const _ActivityRow({required this.icon, required this.color, required this.title, required this.sub, required this.time});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle), child: Icon(icon, color: color, size: 16)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        Text(sub, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ])),
      Text(time, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
    ]),
  );
}

class _RingPainter extends CustomPainter {
  final double score;
  const _RingPainter(this.score);
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 6;
    canvas.drawCircle(c, r, Paint()..color = Colors.white.withOpacity(0.08)..style = PaintingStyle.stroke..strokeWidth = 8);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -pi / 2, 2 * pi * score, false, Paint()..color = AppColors.green..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.round);
  }
  @override bool shouldRepaint(_) => false;
}

