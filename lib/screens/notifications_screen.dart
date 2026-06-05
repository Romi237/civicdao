import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _api = ApiService();
  List<Map<String, dynamic>> _notifs = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    final result = await _api.getNotifications();
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() {
        _notifs = (result['notifications'] as List)
            .map((e) {
              final item = Map<String, dynamic>.from(e as Map);
              item['id'] = (item['id'] ?? item['_id'] ?? '').toString();
              return item;
            })
            .toList();
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
        _error = result['error'] ?? 'Failed to load notifications.';
      });
    }
  }

  Future<void> _markAllRead() async {
    final result = await _api.markNotificationsRead();
    if (result['success'] == true) {
      _load();
    }
  }

  IconData _icon(String type) {
    switch (type) {
      case 'proposal':
        return Icons.article_outlined;
      case 'passed':
        return Icons.check_circle_outline;
      case 'urgent':
        return Icons.access_time_rounded;
      case 'member':
        return Icons.person_add_outlined;
      case 'treasury':
        return Icons.account_balance_wallet_outlined;
      case 'vote':
        return Icons.how_to_vote_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _timeLabel(Map<String, dynamic> notif) {
    final createdAt = notif['createdAt'] != null
        ? DateTime.tryParse(notif['createdAt'].toString())
        : null;
    if (createdAt == null) return 'Just now';
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final today = _notifs.where((n) {
      final createdAt = n['createdAt'] != null
          ? DateTime.tryParse(n['createdAt'].toString())
          : null;
      return createdAt != null &&
          DateTime.now().difference(createdAt).inDays == 0;
    }).toList();
    final earlier = _notifs.where((n) {
      final createdAt = n['createdAt'] != null
          ? DateTime.tryParse(n['createdAt'].toString())
          : null;
      return createdAt == null ||
          DateTime.now().difference(createdAt).inDays > 0;
    }).toList();
    final unread = _notifs.where((n) => !(n['read'] as bool? ?? false)).length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Row(
          children: [
            const Expanded(
              child: Text(
                'Notifications',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (unread > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: const Text(
              'Mark all read',
              style: TextStyle(color: AppColors.purple, fontSize: 12),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.purple),
            )
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _error,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _load,
                        child: const Text(
                          'Retry',
                          style: TextStyle(
                            color: AppColors.purple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    if (today.isNotEmpty) ...[
                      const Text(
                        'Today',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          letterSpacing: 0.06,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...today.map(
                        (n) => _NotifCard(
                          notif: n,
                          icon: _icon(n['type'] as String? ?? ''),
                          onTap: () async {
                            if (!(n['read'] as bool? ?? false)) {
                              await _api.markNotificationsRead(
                                ids: [n['id'].toString()],
                              );
                            }
                            setState(() => n['read'] = true);
                          },
                          timeLabel: _timeLabel(n),
                        ),
                      ),
                    ],
                    if (earlier.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Earlier',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          letterSpacing: 0.06,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...earlier.map(
                        (n) => _NotifCard(
                          notif: n,
                          icon: _icon(n['type'] as String? ?? ''),
                          onTap: () async {
                            if (!(n['read'] as bool? ?? false)) {
                              await _api.markNotificationsRead(
                                ids: [n['id'].toString()],
                              );
                            }
                            setState(() => n['read'] = true);
                          },
                          timeLabel: _timeLabel(n),
                        ),
                      ),
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
  final String timeLabel;
  const _NotifCard({
    required this.notif,
    required this.icon,
    required this.onTap,
    required this.timeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final read = notif['read'] as bool? ?? false;
    final color = Color((notif['color'] as int?) ?? 0xFF8B5CF6);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: read ? AppColors.card : AppColors.card.withValues(alpha: 242),
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(
              color: read ? Colors.transparent : color,
              width: 3,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 38),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif['title'] as String? ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: read ? FontWeight.normal : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notif['body'] as String? ?? '',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    timeLabel,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (!read)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
