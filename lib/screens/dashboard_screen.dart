import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../navigation/app_routes.dart';
import '../models/proposal.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _api = ApiService();

  List<Proposal> _proposals = [];
  int _totalMembers = 0;
  int _activeProposals = 0;
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

    // Load proposals and treasury stats in parallel
    final results = await Future.wait([
      _api.getProposals(status: 'voting'),
      _api.getTreasury(),
    ]);

    if (!mounted) return;

    final proposalRes = results[0];
    final treasuryRes = results[1];

    if (proposalRes['success'] == true) {
      _proposals =
          (proposalRes['proposals'] as List<Proposal>).take(3).toList();
    }
    if (treasuryRes['success'] == true) {
      _totalMembers = treasuryRes['totalMembers'] as int;
      _activeProposals = treasuryRes['activeProposals'] as int;
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: AppColors.purple,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top bar ───────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.menu_rounded, color: Colors.white70),
                    const Text(
                      'CivicDAO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.notifications),
                      child: Stack(
                        children: [
                          const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white70,
                            size: 26,
                          ),
                          if (_activeProposals > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: const BoxDecoration(
                                  color: AppColors.red,
                                  shape: BoxShape.circle,
                                  border: Border.fromBorderSide(
                                    BorderSide(color: AppColors.bg, width: 1.5),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // ── Greeting ──────────────────────────────────────────────────
                Text(
                  'Hello, ${user?.displayName ?? 'Member'} 👋',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const Text(
                  'Together we govern better.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Stats card ────────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3730A3), AppColors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Community Stats',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$_activeProposals Active Vote${_activeProposals == 1 ? '' : 's'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_totalMembers member${_totalMembers == 1 ? '' : 's'} participating',
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.how_to_vote_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Quick actions ─────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _QuickAction(
                      icon: Icons.article_outlined,
                      label: 'Proposals',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.mainShell),
                    ),
                    _QuickAction(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Treasury',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.mainShell),
                    ),
                    _QuickAction(
                      icon: Icons.people_outline_rounded,
                      label: 'Members',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.members),
                    ),
                    _QuickAction(
                      icon: Icons.add_circle_outline_rounded,
                      label: 'Propose',
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.createProposal,
                      ).then((_) => _load()),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ── Active proposals ──────────────────────────────────────────
                SectionHeader(
                  title: 'Active Proposals',
                  actionLabel: 'See all',
                  onAction: () {},
                ),
                const SizedBox(height: 14),

                if (_loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(color: AppColors.purple),
                    ),
                  )
                else if (_error.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _error,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else if (_proposals.isEmpty)
                  AppCard(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.how_to_vote_outlined,
                          color: AppColors.textMuted,
                          size: 40,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'No active votes right now.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.createProposal,
                          ),
                          child: const Text(
                            'Create the first proposal →',
                            style: TextStyle(
                              color: AppColors.purple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ..._proposals.map((p) {
                    final m = p.toUiMap();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.voteDetail,
                          arguments: {'proposal': m, 'proposalId': p.id},
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    m['title'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusBadge(m['status'] as String),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              m['desc'] as String,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              m['time'] as String,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                            if ((m['for'] as int) > 0) ...[
                              const SizedBox(height: 8),
                              VoteProgressBar(
                                forPct: m['for'] as int,
                                againstPct: m['against'] as int,
                                abstainPct: m['abstain'] as int,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),

                // Admin panel shortcut
                if (auth.isAdmin) ...[
                  const SizedBox(height: 20),
                  SectionHeader(
                    title: 'Admin',
                    actionLabel: '',
                    onAction: () {},
                  ),
                  const SizedBox(height: 8),
                  AppCard(
                    onTap: () {},
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_outlined,
                            color: AppColors.amber,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Admin Panel',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Manage proposals and members',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.purple, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      );
}
