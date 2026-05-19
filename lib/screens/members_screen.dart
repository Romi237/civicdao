import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});
  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  String _filter = 'All';
  String _search = '';

  static const _members = [
    {'name': 'Alex Morgan', 'initials': 'AM', 'color': AppColors.purple, 'civic': '1,250', 'participation': '85%', 'role': 'Council'},
    {'name': 'James Kimani', 'initials': 'JK', 'color': AppColors.green, 'civic': '980', 'participation': '91%', 'role': 'Active'},
    {'name': 'Sofia Ferreira', 'initials': 'SF', 'color': AppColors.pink, 'civic': '760', 'participation': '78%', 'role': 'Active'},
    {'name': 'Nadia Benali', 'initials': 'NB', 'color': AppColors.purple, 'civic': '640', 'participation': '62%', 'role': 'Active'},
    {'name': 'Tunde Rasheed', 'initials': 'TR', 'color': AppColors.amber, 'civic': '520', 'participation': '45%', 'role': 'Inactive'},
    {'name': 'Lena Park', 'initials': 'LP', 'color': AppColors.red, 'civic': '410', 'participation': '38%', 'role': 'Inactive'},
    {'name': 'Mei Tanaka', 'initials': 'MT', 'color': AppColors.green, 'civic': '380', 'participation': '55%', 'role': 'Active'},
    {'name': 'David Osei', 'initials': 'DO', 'color': AppColors.amber, 'civic': '310', 'participation': '72%', 'role': 'Active'},
  ];

  List<Map<String, dynamic>> get _filtered => _members.where((m) {
    final matchFilter = _filter == 'All' || m['role'] == _filter;
    final matchSearch = _search.isEmpty || (m['name'] as String).toLowerCase().contains(_search.toLowerCase());
    return matchFilter && matchSearch;
  }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Members'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 16), child: StatusBadge('${_members.length} total')),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
          child: Row(children: [
            Expanded(
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search members...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true, fillColor: AppColors.card,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                ),
              ),
            ),
          ]),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          child: Row(children: ['All', 'Council', 'Active', 'Inactive'].map((f) => GestureDetector(
            onTap: () => setState(() => _filter = f),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _filter == f ? AppColors.purple.withOpacity(0.2) : AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _filter == f ? AppColors.purple.withOpacity(0.5) : AppColors.border),
              ),
              child: Text(f, style: TextStyle(color: _filter == f ? AppColors.purple : AppColors.textSecondary, fontSize: 12, fontWeight: _filter == f ? FontWeight.w600 : FontWeight.normal)),
            ),
          )).toList()),
        ),
        Expanded(
          child: _filtered.isEmpty
              ? const Center(child: Text('No members found', style: TextStyle(color: AppColors.textSecondary)))
              : ListView.separated(
                  padding: const EdgeInsets.all(18),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) {
                    final m = _filtered[i];
                    return AppCard(
                      child: Row(children: [
                        UserAvatar(initials: m['initials'] as String, color: m['color'] as Color, size: 44),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(m['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 3),
                          Text('${m['civic']} CIVIC · ${m['participation']} participation', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        ])),
                        StatusBadge(m['role'] as String),
                      ]),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}

