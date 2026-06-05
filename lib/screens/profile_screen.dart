import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../navigation/app_routes.dart';
import '../services/auth_service.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _shortId(String id) {
    if (id.length <= 10) return id;
    return '${id.substring(0, 6)}...${id.substring(id.length - 4)}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  int _participation(int votes) => (votes * 10).clamp(0, 100);
  int _votingPower(int votes) => votes * 125;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: Text(
            'No profile data available.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final votedCount = user.votedProposals.length;
    final participation = _participation(votedCount);
    final votingPower = _votingPower(votedCount);
    final roleLabel = user.role.isNotEmpty
        ? '${user.role[0].toUpperCase()}${user.role.substring(1)}'
        : 'Member';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(Icons.menu_rounded, color: Colors.white70),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF3730A3), AppColors.purple],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name.isNotEmpty ? user.name : user.email,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _shortId(user.id),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Joined ${_formatDate(user.joinDate)}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  StatusBadge(roleLabel),
                ],
              ),
            ),
            const SizedBox(height: 22),
            // Stats
            AppCard(
              padding: EdgeInsets.zero,
              child: Row(
                children: [
                  Expanded(
                    child: _StatCell(
                      value: votingPower.toString(),
                      label: 'Voting Power',
                    ),
                  ),
                  Container(width: 1, height: 40, color: AppColors.border),
                  Expanded(
                    child: _StatCell(
                      value: votedCount.toString(),
                      label: 'Proposals Voted',
                    ),
                  ),
                  Container(width: 1, height: 40, color: AppColors.border),
                  Expanded(
                    child: _StatCell(
                      value: '$participation%',
                      label: 'Participation',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            // Participation score
            const SectionHeader(title: 'Participation Score'),
            const SizedBox(height: 14),
            AppCard(
              child: Row(
                children: [
                  SizedBox(
                    width: 82,
                    height: 82,
                    child: CustomPaint(
                      painter: _RingPainter(participation / 100),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              participation.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Score',
                              style: TextStyle(
                                color: AppColors.green,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Your activity is based on your voting participation.",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _ActivityRow(
                          icon: Icons.how_to_vote_rounded,
                          color: AppColors.green,
                          title: 'Votes cast',
                          sub: '$votedCount proposals',
                          time: 'Recent',
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        _ActivityRow(
                          icon: Icons.person_outline_rounded,
                          color: AppColors.purple,
                          title: 'Role',
                          sub: roleLabel,
                          time: 'Current',
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        _ActivityRow(
                          icon:
                              user.isActive ? Icons.check_circle : Icons.block,
                          color:
                              user.isActive ? AppColors.green : AppColors.red,
                          title: 'Account status',
                          sub: user.isActive ? 'Active' : 'Suspended',
                          time: 'Updated',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
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
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}

class _ActivityRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, sub, time;
  const _ActivityRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.sub,
    required this.time,
  });
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    sub,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ],
        ),
      );
}

class _RingPainter extends CustomPainter {
  final double score;
  const _RingPainter(this.score);
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 6;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -pi / 2,
      2 * pi * score,
      false,
      Paint()
        ..color = AppColors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
