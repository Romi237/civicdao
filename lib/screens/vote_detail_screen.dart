import 'package:flutter/material.dart';
import '../navigation/app_routes.dart';
import '../models/proposal.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';

class VoteDetailScreen extends StatefulWidget {
  final Map<String, dynamic> proposal;
  final String proposalId;
  const VoteDetailScreen({
    super.key,
    required this.proposal,
    required this.proposalId,
  });
  @override
  State<VoteDetailScreen> createState() => _VoteDetailScreenState();
}

class _VoteDetailScreenState extends State<VoteDetailScreen> {
  final _api = ApiService();

  // null = not selected, true = yes, false = no
  bool? _selected;
  bool _submitting = false;
  bool _hasVoted = false;
  late Map<String, dynamic> _proposal;

  @override
  void initState() {
    super.initState();
    _proposal = Map<String, dynamic>.from(widget.proposal);
    _hasVoted = !AuthService().canVoteOn(widget.proposalId);
  }

  Future<void> _submit() async {
    if (_selected == null) return;
    setState(() => _submitting = true);

    final result = await _api.submitVote(widget.proposalId, _selected!);

    if (!mounted) return;
    setState(() => _submitting = false);

    if (result['success'] == true) {
      // Update local proposal data with fresh counts from server
      final updated = result['proposal'] as Proposal;
      AuthService().addVotedProposal(widget.proposalId);
      setState(() {
        _hasVoted = true;
        _proposal = updated.toUiMap();
      });
      Navigator.pushNamed(
        context,
        AppRoutes.voteSubmitted,
        arguments: {
          'proposal': _proposal,
          'vote': _selected! ? 'for' : 'against',
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Vote failed.'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _proposal;
    final isActive = (p['rawStatus'] ?? p['status']) == 'voting' ||
        (p['status'] as String).toLowerCase() == 'active';
    final forPct = p['for'] as int? ?? 0;
    final againstPct = p['against'] as int? ?? 0;
    final abstainPct = p['abstain'] as int? ?? 0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Vote Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusBadge(p['status'] as String? ?? ''),
                Text(
                  p['time'] as String? ?? '',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              p['title'] as String? ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              p['desc'] as String? ?? '',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),

            // Meta row
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                _Meta(
                  Icons.person_outline,
                  p['author'] as String? ?? 'Unknown',
                ),
                if ((p['budget'] as num? ?? 0) > 0)
                  _Meta(
                    Icons.currency_exchange,
                    'FCFA ${(p['budget'] as num).toStringAsFixed(0)} budget',
                  ),
                _Meta(
                  Icons.label_outline,
                  p['category'] as String? ?? 'General',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Current results ───────────────────────────────────────────
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Results',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  VoteProgressBar(
                    forPct: forPct,
                    againstPct: againstPct,
                    abstainPct: abstainPct,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ResultChip('For', '$forPct%', AppColors.green),
                      _ResultChip('Against', '$againstPct%', AppColors.red),
                      _ResultChip(
                        'Abstain',
                        '$abstainPct%',
                        AppColors.textMuted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Voting section ────────────────────────────────────────────
            if (_hasVoted) ...[
              AppCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vote submitted',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'You have already voted on this proposal.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (!isActive) ...[
              const AppCard(
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.amber, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This proposal is not open for voting yet.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const Text(
                'Cast your vote',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select your position on this proposal.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _VoteButton(
                      label: 'Vote For',
                      icon: Icons.thumb_up_outlined,
                      color: AppColors.green,
                      selected: _selected == true,
                      onTap: () => setState(() => _selected = true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _VoteButton(
                      label: 'Vote Against',
                      icon: Icons.thumb_down_outlined,
                      color: AppColors.red,
                      selected: _selected == false,
                      onTap: () => setState(() => _selected = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _submitting
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.purple),
                    )
                  : PrimaryButton(
                      label: _selected == null
                          ? 'Select your vote first'
                          : _selected!
                              ? 'Confirm — Vote For'
                              : 'Confirm — Vote Against',
                      onTap: _submit,
                      enabled: _selected != null,
                      color: _selected == null
                          ? null
                          : _selected!
                              ? AppColors.green
                              : AppColors.red,
                    ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _Meta extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Meta(this.icon, this.label);
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      );
}

class _ResultChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _ResultChip(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      );
}

class _VoteButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _VoteButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.15) : AppColors.card,
            border: Border.all(
              color: selected ? color : AppColors.border,
              width: selected ? 1.5 : 0.5,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 28, color: selected ? color : AppColors.textMuted),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? color : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
}
