import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});
  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final _api = ApiService();

  List<User> _members = [];
  bool _loading = true;
  String _error = '';
  String _search = '';

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
    final result = await _api.getUsers();
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() {
        _members = result['users'] as List<User>;
        _loading = false;
      });
    } else {
      setState(() {
        _error = result['error'] ?? 'Failed.';
        _loading = false;
      });
    }
  }

  List<User> get _filtered {
    if (_search.trim().isEmpty) return _members;
    final q = _search.toLowerCase();
    return _members
        .where(
          (u) =>
              u.name.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> _action(String action, User member) async {
    Map<String, dynamic> result;
    switch (action) {
      case 'suspend':
        result = await _api.suspendUser(member.id);
        break;
      case 'reactivate':
        result = await _api.reactivateUser(member.id);
        break;
      case 'promote':
        result = await _api.promoteUser(member.id);
        break;
      default:
        return;
    }
    if (!mounted) return;
    if (result['success'] == true) {
      _load();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Done for ${member.name}.'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Action failed.'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showOptions(User member) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                member.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (!member.isAdmin)
              ListTile(
                leading: const Icon(
                  Icons.admin_panel_settings_outlined,
                  color: AppColors.amber,
                ),
                title: const Text(
                  'Promote to Admin',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _action('promote', member);
                },
              ),
            if (member.isActive)
              ListTile(
                leading: const Icon(Icons.block, color: AppColors.red),
                title: const Text(
                  'Suspend Account',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _action('suspend', member);
                },
              )
            else
              ListTile(
                leading: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.green,
                ),
                title: const Text(
                  'Reactivate Account',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _action('reactivate', member);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthService>().isAdmin;
    final myId = context.read<AuthService>().currentUser?.id;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text('Members (${_members.length})')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search by name or email…',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.purple),
                  )
                : _error.isNotEmpty
                    ? Center(
                        child: Text(
                          _error,
                          style:
                              const TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: AppColors.purple,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: _filtered.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final m = _filtered[i];
                            return AppCard(
                              child: Row(
                                children: [
                                  // Avatar
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor:
                                        AppColors.purple.withValues(
                                      alpha: 0.2,
                                    ),
                                    child: Text(
                                      m.initials,
                                      style: const TextStyle(
                                        color: AppColors.purple,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              m.name.isNotEmpty
                                                  ? m.name
                                                  : m.email,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (m.id == myId) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.purple
                                                      .withValues(alpha: 0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Text(
                                                  'You',
                                                  style: TextStyle(
                                                    color: AppColors.purple,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          m.email,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            _RoleBadge(
                                              m.isAdmin ? 'Admin' : 'Member',
                                              m.isAdmin
                                                  ? AppColors.amber
                                                  : AppColors.textMuted,
                                            ),
                                            if (!m.isActive) ...[
                                              const SizedBox(width: 6),
                                              const _RoleBadge(
                                                'Suspended',
                                                AppColors.red,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isAdmin && m.id != myId)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.more_vert,
                                        color: AppColors.textMuted,
                                      ),
                                      onPressed: () => _showOptions(m),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _RoleBadge(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      );
}
