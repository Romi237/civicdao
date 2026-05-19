import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifs = [
    {'id': 1, 'type': 'proposal', 'title': 'New proposal submitted', 'body': '"Partnership with GreenDAO" is now open for review before voting.', 'time': '2 hours ago', 'read': false, 'color': AppColors.purple},
    {'id': 2, 'type': 'passed', 'title': 'Proposal passed', 'body': '"Q3 Operating Budget" passed with 81% approval. Funds disbursed.', 'time': '5 hours ago', 'read': false, 'color': AppColors.green},
    {'id': 3, 'type': 'urgent', 'title': 'Vote closing soon', 'body': '"Infrastructure Upgrade" vote ends in 6 hours. You haven\'t voted yet.', 'time': 'Just now', 'read': false, 'color': AppColors.amber},
    {'id': 4, 'type': 'member', 'title': 'New member joined', 'body': 'Lena Park joined the DAO with 410 CIVIC.', 'time': 'Yesterday, 3:41 PM', 'read': true, 'color': AppColors.textMuted},
    {'id': 5, 'type': 'treasury', 'title': 'Treasury update', 'body': '2,000 CIVIC received from 0x8a...3f2b. Treasury now at 56,780 CIVIC.', 'time': '2 days ago', 'read': true, 'color': AppColors.green},
    {'id': 6, 'type': 'vote', 'title': 'Voting opened', 'body': '"Fund Community Event" is now open for voting. Ends in 3 days.', 'time': '3 days ago', 'read': true, 'color': AppColors.purple},
  ];

  IconData _icon(String type) {
    switch (type) {
      case 'proposal': return Icons.article_outlined;
      case 'passed': return Icons.check_circle_outline;
      case 'urgent': return Icons.access_time_rounded;
      case 'member': return Icons.person_add_outlined;
      case 'treasury': return Icons.account_balance_wallet_outlined;
      case 'vote': return Icons.how_to_vote_outlined;
      default: return Icons.notifications_outlined;
    }
  }

  void _markAllRead() => setState(() { for (final n in _notifs) n['read'] = true; });

  @override
  Widget build(BuildContext context) {
    final today = _notifs.where((n) => ['2 hours ago', '5 hours ago', 'Just now'].contains(n['time'])).toList();
    final earlier = _notifs.where((n) => !['2 hours ago', '5 hours ago', 'Just now'].contains(n['time'])).toList();
    final unread = _notifs.where((n) => !(n['read'] as bool)).length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('Notifications'),
          if (unread > 0) ...[
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(10)), child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
          ],
        ]),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        actions: [
          TextButton(onPressed: _markAllRead, child: const Text('Mark all read', style: TextStyle(color: AppColors.purple, fontSize: 12))),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          if (today.isNotEmpty) ...[
            const Text('Today', style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 0.06, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            ...today.map((n) => _NotifCard(notif: n, icon: _icon(n['type'] as String), onTap: () => setState(() => n['read'] = true))),
          ],
          if (earlier.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Earlier', style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 0.06, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            ...earlier.map((n) => _NotifCard(notif: n, icon: _icon(n['type'] as String), onTap: () => setState(() => n['read'] = true))),
          ],
        ],
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final Map<String, dynamic> notif;
  final IconData icon;
  final VoidCallback onTap;
  const _NotifCard({required this.notif, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final read = notif['read'] as bool;
    final color = notif['color'] as Color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: read ? AppColors.card : AppColors.card.withOpacity(0.95),
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: read ? Colors.transparent : color, width: 3)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle), child: Icon(icon, color: color, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(notif['title'] as String, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: read ? FontWeight.normal : FontWeight.w600)),
            const SizedBox(height: 3),
            Text(notif['body'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4)),
            const SizedBox(height: 5),
            Text(notif['time'] as String, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ])),
          if (!read) Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 4), decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle)),
        ]),
      ),
    );
  }
}

