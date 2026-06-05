import 'package:flutter/material.dart';
import '../navigation/app_routes.dart';
import '../models/proposal.dart';
import '../services/api_service.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';

class ProposalsScreen extends StatefulWidget {
  const ProposalsScreen({super.key});
  @override
  State<ProposalsScreen> createState() => _ProposalsScreenState();
}

class _ProposalsScreenState extends State<ProposalsScreen>
    with SingleTickerProviderStateMixin {
  final _api = ApiService();
  late TabController _tab;

  // Parallel lists — one per tab
  final Map<int, List<Proposal>> _cache = {};
  final Map<int, bool> _loading = {};
  final Map<int, String> _errors = {};

  static const _statuses = [null, 'voting', 'pending', 'accepted', 'rejected'];
  static const _labels = ['All', 'Active', 'Upcoming', 'Passed', 'Closed'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _labels.length, vsync: this);
    _tab.addListener(() {
      if (!_tab.indexIsChanging) _loadTab(_tab.index);
    });
    _loadTab(0); // load All immediately
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _loadTab(int idx) async {
    if (_cache.containsKey(idx)) return; // already loaded
    setState(() {
      _loading[idx] = true;
      _errors[idx] = '';
    });

    final result = await _api.getProposals(status: _statuses[idx]);
    if (!mounted) return;

    setState(() {
      _loading[idx] = false;
      if (result['success'] == true) {
        _cache[idx] = result['proposals'] as List<Proposal>;
      } else {
        _errors[idx] = result['error'] ?? 'Failed to load.';
      }
    });
  }

  Future<void> _refresh() async {
    _cache.clear();
    await _loadTab(_tab.index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Proposals'),
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(Icons.menu_rounded, color: Colors.white70),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.purple),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.createProposal).then((
                  _,
                ) {
                  _cache.clear();
                  _loadTab(_tab.index);
                }),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.purple,
          labelColor: AppColors.purple,
          unselectedLabelColor: Colors.white38,
          isScrollable: true,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          tabs: _labels.map((l) => Tab(text: l)).toList(),
          onTap: _loadTab,
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: List.generate(_labels.length, (i) => _buildTab(i)),
      ),
    );
  }

  Widget _buildTab(int idx) {
    if (_loading[idx] == true) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.purple),
      );
    }
    if (_errors[idx]?.isNotEmpty == true) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errors[idx]!,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                _cache.remove(idx);
                _loadTab(idx);
              },
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
      );
    }
    final proposals = _cache[idx] ?? [];
    if (proposals.isEmpty) {
      return const Center(
        child: Text(
          'No proposals here',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.purple,
      child: ListView.separated(
        padding: const EdgeInsets.all(18),
        itemCount: proposals.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final p = proposals[i];
          final m = p.toUiMap();
          return AppCard(
            onTap: () => Navigator.pushNamed(
              ctx,
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
                        p.title,
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
                  p.description,
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
                  p.timeLabel,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
                if (p.totalVotes > 0) ...[
                  const SizedBox(height: 10),
                  VoteProgressBar(
                    forPct: p.forPct,
                    againstPct: p.againstPct,
                    abstainPct: p.abstainPct,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
