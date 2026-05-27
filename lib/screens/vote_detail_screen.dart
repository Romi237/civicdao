import 'package:flutter/material.dart';
import 'dart:math';
import '../navigation/app_routes.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';

// ─────────────────────────────────────────────
//  Vote Detail Screen
// ─────────────────────────────────────────────
class VoteDetailScreen extends StatefulWidget {
  final Map<String, dynamic> proposal;
  const VoteDetailScreen({super.key, required this.proposal});
  @override
  State<VoteDetailScreen> createState() => _VoteDetailScreenState();
}

class _VoteDetailScreenState extends State<VoteDetailScreen> {
  String? _selected;
  bool _expanded = false;

  void _castVote(String vote) {
    setState(() => _selected = vote);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        AppRoutes.voteSubmitted,
        arguments: {'proposal': widget.proposal, 'vote': vote},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.proposal;
    final forPct = p['for'] as int;
    final againstPct = p['against'] as int;
    final abstainPct = p['abstain'] as int;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.share_outlined, color: Colors.white70))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            StatusBadge(p['status'] as String),
            const Spacer(),
            Text(p['time'] as String, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ]),
          const SizedBox(height: 14),
          Text(p['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.3)),
          const SizedBox(height: 8),
          Text(p['desc'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
          const SizedBox(height: 20),
          // Proposer
          const Row(children: [
            UserAvatar(initials: 'AM', color: AppColors.purple, size: 38),
            SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Proposed by', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              Text('Alex Morgan', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
            Spacer(),
            Text('May 12, 2024', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ]),
          const SizedBox(height: 22),
          // Results card
          if (forPct > 0) ...[
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Current Results', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('Total Votes', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    Text('12,345 CIVIC', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  ]),
                ]),
                const SizedBox(height: 14),
                VoteProgressBar(forPct: forPct, againstPct: againstPct, abstainPct: abstainPct, height: 8),
                const SizedBox(height: 14),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _ResultStat(label: 'For', pct: '$forPct%', civic: '8,395 CIVIC', color: AppColors.green),
                  _ResultStat(label: 'Against', pct: '$againstPct%', civic: '2,593 CIVIC', color: AppColors.red),
                  _ResultStat(label: 'Abstain', pct: '$abstainPct%', civic: '1,357 CIVIC', color: AppColors.textSecondary),
                ]),
              ]),
            ),
            const SizedBox(height: 22),
          ],
          // About
          const Text('About this proposal', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Text(
            'This event will bring our community together, share knowledge, and strengthen our mission. The funds will be used for venue, food, and speakers. All receipts will be published on-chain within 30 days.',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.6),
            maxLines: _expanded ? null : 3,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(padding: const EdgeInsets.only(top: 6), child: Row(children: [
              Text(_expanded ? 'Show less' : 'View full details', style: const TextStyle(color: AppColors.purple, fontSize: 13, fontWeight: FontWeight.w600)),
              Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: AppColors.purple, size: 18),
            ])),
          ),
          const SizedBox(height: 28),
          const Text('Cast Your Vote', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Your voting power: 1,250 CIVIC', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _VoteBtn(label: 'For', icon: Icons.thumb_up_rounded, color: AppColors.green, selected: _selected == 'For', onTap: () => _castVote('For'))),
            const SizedBox(width: 10),
            Expanded(child: _VoteBtn(label: 'Against', icon: Icons.thumb_down_rounded, color: AppColors.red, selected: _selected == 'Against', onTap: () => _castVote('Against'))),
            const SizedBox(width: 10),
            Expanded(child: _VoteBtn(label: 'Abstain', icon: Icons.remove_circle_outline, color: AppColors.textSecondary, selected: _selected == 'Abstain', onTap: () => _castVote('Abstain'))),
          ]),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label, pct, civic;
  final Color color;
  const _ResultStat({required this.label, required this.pct, required this.civic, required this.color});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(label, style: TextStyle(color: color, fontSize: 12)),
    const SizedBox(height: 4),
    Text(pct, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 2),
    Text(civic, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
  ]);
}

class _VoteBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _VoteBtn({required this.label, required this.icon, required this.color, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: selected ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? color : color.withValues(alpha: 0.3)),
      ),
      child: Column(children: [
        Icon(icon, color: selected ? Colors.white : color, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: selected ? Colors.white : color, fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────
//  Vote Submitted Screen
// ─────────────────────────────────────────────
class VoteSubmittedScreen extends StatefulWidget {
  final Map<String, dynamic> proposal;
  final String vote;
  const VoteSubmittedScreen({super.key, required this.proposal, required this.vote});
  @override
  State<VoteSubmittedScreen> createState() => _VoteSubmittedScreenState();
}

class _VoteSubmittedScreenState extends State<VoteSubmittedScreen> with TickerProviderStateMixin {
  late AnimationController _checkCtrl, _confettiCtrl;
  late Animation<double> _scale, _opacity;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _confettiCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _scale = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut));
    _opacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _checkCtrl, curve: Curves.easeIn));
    final rng = Random();
    final colors = [AppColors.purple, AppColors.green, AppColors.amber, AppColors.red, Colors.pink, Colors.cyan];
    for (int i = 0; i < 36; i++) {
      _particles.add(_Particle(x: rng.nextDouble(), y: rng.nextDouble() * 0.5, color: colors[rng.nextInt(colors.length)], size: rng.nextDouble() * 8 + 4, speed: rng.nextDouble() * 0.3 + 0.1));
    }
    Future.delayed(const Duration(milliseconds: 200), () => _checkCtrl.forward());
  }

  @override
  void dispose() { _checkCtrl.dispose(); _confettiCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(children: [
        AnimatedBuilder(animation: _confettiCtrl, builder: (_, __) => CustomPaint(painter: _ConfettiPainter(_particles, _confettiCtrl.value), child: const SizedBox.expand())),
        SafeArea(child: Column(children: [
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            AnimatedBuilder(animation: _checkCtrl, builder: (_, __) => Opacity(
              opacity: _opacity.value,
              child: Transform.scale(scale: _scale.value, child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.green, boxShadow: [BoxShadow(color: AppColors.green.withValues(alpha: 0.35), blurRadius: 30, spreadRadius: 10)]),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 56),
              )),
            )),
            const SizedBox(height: 32),
            const Text('Vote Submitted!', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Your vote has been recorded\nsuccessfully.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.5)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.how_to_vote_outlined, color: AppColors.purple, size: 16),
                const SizedBox(width: 6),
                Text('You voted: ${widget.vote}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ]),
            ),
          ])),
          Padding(padding: const EdgeInsets.all(24), child: Column(children: [
            PrimaryButton(label: 'Great!', onTap: () => Navigator.popUntil(context, (r) => r.isFirst), color: AppColors.green),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: _DimVoteBtn(label: 'For', icon: Icons.thumb_up_rounded, color: AppColors.green, active: widget.vote == 'For')),
              const SizedBox(width: 10),
              Expanded(child: _DimVoteBtn(label: 'Against', icon: Icons.thumb_down_rounded, color: AppColors.red, active: widget.vote == 'Against')),
              const SizedBox(width: 10),
              Expanded(child: _DimVoteBtn(label: 'Abstain', icon: Icons.remove_circle_outline, color: AppColors.textSecondary, active: widget.vote == 'Abstain')),
            ]),
            const SizedBox(height: 10),
            const Text('Your voting power: 1,250 CIVIC', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ])),
        ])),
      ]),
    );
  }
}

class _DimVoteBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool active;
  const _DimVoteBtn({required this.label, required this.icon, required this.color, required this.active});
  @override
  Widget build(BuildContext context) => Opacity(
    opacity: active ? 1.0 : 0.3,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.4))),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

class _Particle { final double x, y, size, speed; final Color color; const _Particle({required this.x, required this.y, required this.size, required this.speed, required this.color}); }

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  const _ConfettiPainter(this.particles, this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()..color = p.color.withValues(alpha: 0.8);
      final dy = (p.y + progress * p.speed * 2) % 1.1;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(p.x * size.width, dy * size.height), width: p.size, height: p.size * 0.5), const Radius.circular(2)), paint);
    }
  }
  @override bool shouldRepaint(_) => true;
}


