import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';

class DelegateScreen extends StatefulWidget {
  const DelegateScreen({super.key});
  @override
  State<DelegateScreen> createState() => _DelegateScreenState();
}

class _DelegateScreenState extends State<DelegateScreen> {
  String? _delegated;

  static const _delegates = [
    {'name': 'James Kimani', 'initials': 'JK', 'color': AppColors.green, 'participation': '91%', 'delegators': 3},
    {'name': 'Sofia Ferreira', 'initials': 'SF', 'color': AppColors.pink, 'participation': '78%', 'delegators': 1},
    {'name': 'Nadia Benali', 'initials': 'NB', 'color': AppColors.amber, 'participation': '62%', 'delegators': 0},
  ];

  void _delegate(String name) {
    setState(() => _delegated = name);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Votes delegated to $name'),
      backgroundColor: AppColors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Delegate votes'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Power card
          Container(
            width: double.infinity, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF3730A3), AppColors.purple]), borderRadius: BorderRadius.circular(18)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Your voting power', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              const Text('1,250 CIVIC', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(_delegated == null ? 'Currently not delegated' : 'Delegated to $_delegated', style: const TextStyle(color: Colors.white60, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 24),
          const Text('How delegation works', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          const _Step(num: '1', title: 'Choose a delegate', desc: 'Pick a trusted member to vote on your behalf.'),
          const _Step(num: '2', title: 'Set the scope', desc: 'All proposals, or specific categories only.'),
          const _Step(num: '3', title: 'Revoke anytime', desc: 'You can take back your votes at any time.', last: true),
          const SizedBox(height: 24),
          const Text('Top delegates', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Column(children: _delegates.asMap().entries.map((e) {
              final d = e.value;
              final isLast = e.key == _delegates.length - 1;
              final isDelegated = _delegated == d['name'];
              return Column(children: [
                Padding(padding: const EdgeInsets.symmetric(vertical: 13), child: Row(children: [
                  UserAvatar(initials: d['initials'] as String, color: d['color'] as Color, size: 42),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(d['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('${d['participation']} participation · ${d['delegators']} delegator${(d['delegators'] as int) != 1 ? 's' : ''}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  ])),
                  GestureDetector(
                    onTap: () => _delegate(d['name'] as String),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDelegated ? AppColors.green.withValues(alpha: 0.2) : AppColors.purple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isDelegated ? AppColors.green.withValues(alpha: 0.4) : AppColors.purple.withValues(alpha: 0.3)),
                      ),
                      child: Text(isDelegated ? '✓ Delegated' : 'Delegate', style: TextStyle(color: isDelegated ? AppColors.green : AppColors.purple, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ])),
                if (!isLast) const Divider(color: AppColors.border, height: 1),
              ]);
            }).toList()),
          ),
          const SizedBox(height: 20),
          if (_delegated != null) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () { setState(() => _delegated = null); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delegation removed'), backgroundColor: AppColors.red, behavior: SnackBarBehavior.floating)); },
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.red, side: const BorderSide(color: AppColors.red), minimumSize: const Size(double.infinity, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Remove delegation'),
              ),
            ),
          ],
          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String num, title, desc;
  final bool last;
  const _Step({required this.num, required this.title, required this.desc, this.last = false});
  @override
  Widget build(BuildContext context) => Column(children: [
    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 28, height: 28, decoration: const BoxDecoration(color: AppColors.purple, shape: BoxShape.circle), child: Center(child: Text(num, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4)),
      ])),
    ]),
    if (!last) Padding(padding: const EdgeInsets.only(left: 13, top: 3, bottom: 3), child: Container(width: 2, height: 22, color: AppColors.border)),
  ]);
}


