import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';

class TreasuryScreen extends StatelessWidget {
  const TreasuryScreen({super.key});

  static const _txns = [
    {'type': 'in', 'label': 'Received', 'from': 'From 0x8a...3f2b', 'amount': '+2,000', 'date': 'May 14, 2024'},
    {'type': 'out', 'label': 'Sent', 'from': 'To 0x7d...9c21', 'amount': '-1,500', 'date': 'May 13, 2024'},
    {'type': 'in', 'label': 'Received', 'from': 'From 0x22...6a7e', 'amount': '+5,000', 'date': 'May 12, 2024'},
    {'type': 'out', 'label': 'Sent', 'from': 'To 0x9b...4d11', 'amount': '-750', 'date': 'May 11, 2024'},
  ];

  static const _allocations = [
    {'label': 'Operations', 'pct': 34, 'amount': '19,305', 'color': AppColors.purple},
    {'label': 'Community Grants', 'pct': 28, 'amount': '15,898', 'color': AppColors.green},
    {'label': 'Infrastructure', 'pct': 22, 'amount': '12,492', 'color': AppColors.amber},
    {'label': 'Reserve', 'pct': 16, 'amount': '9,085', 'color': AppColors.red},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Treasury'),
        leading: const Padding(padding: EdgeInsets.only(left: 16), child: Icon(Icons.menu_rounded, color: Colors.white70)),
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.visibility_outlined, color: Colors.white70))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Balance card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1A1560), AppColors.purple], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Treasury Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 10),
              const Text('56,780 CIVIC', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('≈ \$25,551.00', style: TextStyle(color: Colors.white60, fontSize: 14)),
              const SizedBox(height: 16),
              SizedBox(height: 50, child: CustomPaint(painter: _MiniChart(), child: const SizedBox.expand())),
            ]),
          ),
          const SizedBox(height: 26),
          const Text('Allocation Breakdown', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          ..._allocations.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(a['label'] as String, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                Text('${a['amount']} CIVIC (${a['pct']}%)', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (a['pct'] as int) / 100,
                  backgroundColor: Colors.white.withValues(alpha: 0.07),
                  valueColor: AlwaysStoppedAnimation<Color>(a['color'] as Color),
                  minHeight: 7,
                ),
              ),
            ]),
          )),
          const SizedBox(height: 26),
          SectionHeader(title: 'Recent Transactions', actionLabel: 'See all', onAction: () {}),
          const SizedBox(height: 14),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Column(
              children: _txns.asMap().entries.map((e) {
                final t = e.value;
                final isIn = t['type'] == 'in';
                final isLast = e.key == _txns.length - 1;
                return Column(children: [
                  Padding(padding: const EdgeInsets.symmetric(vertical: 13), child: Row(children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(color: (isIn ? AppColors.green : AppColors.red).withValues(alpha: 0.15), shape: BoxShape.circle),
                      child: Icon(isIn ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: isIn ? AppColors.green : AppColors.red, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(t['label'] as String, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      Text(t['from'] as String, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('${t['amount']} CIVIC', style: TextStyle(color: isIn ? AppColors.green : AppColors.red, fontSize: 13, fontWeight: FontWeight.w600)),
                      Text(t['date'] as String, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ]),
                  ])),
                  if (!isLast) const Divider(color: AppColors.border, height: 1),
                ]);
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

class _MiniChart extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pts = [0.8, 0.6, 0.7, 0.4, 0.5, 0.3, 0.45, 0.2, 0.35, 0.1];
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.65)..strokeWidth = 2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    final fill = Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white.withValues(alpha: 0.12), Colors.transparent]).createShader(Rect.fromLTWH(0, 0, size.width, size.height))..style = PaintingStyle.fill;
    final path = Path(), fillPath = Path();
    for (int i = 0; i < pts.length; i++) {
      final x = (i / (pts.length - 1)) * size.width;
      final y = pts[i] * size.height;
      if (i == 0) { path.moveTo(x, y); fillPath.moveTo(x, y); } else { path.lineTo(x, y); fillPath.lineTo(x, y); }
    }
    fillPath..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(fillPath, fill);
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(_) => false;
}


