import 'package:flutter/material.dart';
import '../navigation/app_routes.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';

class ProposalsScreen extends StatefulWidget {
  const ProposalsScreen({super.key});
  @override
  State<ProposalsScreen> createState() => _ProposalsScreenState();
}

class _ProposalsScreenState extends State<ProposalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  static const _all = [
    {'title': 'Fund Community Event', 'desc': 'Allocate 5,000 CIVIC for our annual community meetup and workshops.', 'status': 'Active', 'time': 'Ends in 2d 14h', 'for': 68, 'against': 21, 'abstain': 11},
    {'title': 'Update Governance Rules', 'desc': 'Propose changes to improve governance transparency and member participation.', 'status': 'Active', 'time': 'Ends in 5d 3h', 'for': 75, 'against': 15, 'abstain': 10},
    {'title': 'Partnership with GreenDAO', 'desc': 'Propose a strategic partnership with GreenDAO for eco-initiatives.', 'status': 'Upcoming', 'time': 'Starts in 1d 6h', 'for': 0, 'against': 0, 'abstain': 0},
    {'title': 'New Grant Program', 'desc': 'Establish a 10,000 CIVIC grant fund for community developers.', 'status': 'Closed', 'time': 'Ended 3d ago', 'for': 55, 'against': 30, 'abstain': 15},
    {'title': 'Q3 Operating Budget', 'desc': 'Approve the Q3 operating budget of 8,000 CIVIC for operational expenses.', 'status': 'Closed', 'time': 'Ended 1w ago', 'for': 81, 'against': 12, 'abstain': 7},
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  List<Map<String, dynamic>> _filtered(String? status) => status == null ? List<Map<String,dynamic>>.from(_all) : _all.where((p) => p['status'] == status).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Proposals'),
        leading: const Padding(padding: EdgeInsets.only(left: 16), child: Icon(Icons.menu_rounded, color: Colors.white70)),
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.tune_rounded, color: Colors.white70))],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.purple,
          labelColor: AppColors.purple,
          unselectedLabelColor: Colors.white38,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [Tab(text: 'All'), Tab(text: 'Active'), Tab(text: 'Upcoming'), Tab(text: 'Closed')],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [null, 'Active', 'Upcoming', 'Closed'].map((s) => _buildList(_filtered(s))).toList(),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return const Center(child: Text('No proposals here', style: TextStyle(color: AppColors.textSecondary)));
    return ListView.separated(
      padding: const EdgeInsets.all(18),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final p = items[i];
        return AppCard(
          onTap: () => Navigator.pushNamed(ctx, AppRoutes.voteDetail, arguments: {'proposal': p}),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(p['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
              const SizedBox(width: 8),
              StatusBadge(p['status'] as String),
            ]),
            const SizedBox(height: 6),
            Text(p['desc'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4)),
            const SizedBox(height: 8),
            Text(p['time'] as String, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            if ((p['for'] as int) > 0) ...[
              const SizedBox(height: 10),
              VoteProgressBar(forPct: p['for'] as int, againstPct: p['against'] as int, abstainPct: p['abstain'] as int),
            ],
          ]),
        );
      },
    );
  }
}

