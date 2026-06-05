import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';

class TreasuryScreen extends StatefulWidget {
  const TreasuryScreen({super.key});
  @override
  State<TreasuryScreen> createState() => _TreasuryScreenState();
}

class _TreasuryScreenState extends State<TreasuryScreen> {
  final _api = ApiService();

  double _balance = 0;
  List _transactions = [];
  int _totalProposals = 0;
  int _activeProposals = 0;
  int _totalMembers = 0;
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
    final result = await _api.getTreasury();
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() {
        _balance = result['balance'] as double;
        _transactions = result['transactions'] as List;
        _totalProposals = result['totalProposals'] as int;
        _activeProposals = result['activeProposals'] as int;
        _totalMembers = result['totalMembers'] as int;
        _loading = false;
      });
    } else {
      setState(() {
        _error = result['error'] ?? 'Failed.';
        _loading = false;
      });
    }
  }

  String _formatAmount(num amount) {
    if (amount >= 1000000) return 'FCFA ${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return 'FCFA ${(amount / 1000).toStringAsFixed(1)}K';
    return 'FCFA ${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = Provider.of<AuthService>(context).isAdmin;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Treasury'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.purple,
              icon: const Icon(Icons.add),
              label: const Text('Add Transaction'),
              onPressed: () => _showAddTransaction(context),
            )
          : null,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.purple),
            )
          : _error.isNotEmpty
              ? Center(
                  child: Text(
                    _error,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.purple,
                  child: _buildContent(),
                ),
    );
  }

  Widget _buildContent() => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Balance card ─────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3730A3), AppColors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Community Balance',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatAmount(_balance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Total treasury funds',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Stats row ────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Proposals',
                    value: '$_totalProposals',
                    icon: Icons.description_outlined,
                    color: AppColors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Active Votes',
                    value: '$_activeProposals',
                    icon: Icons.how_to_vote_outlined,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Members',
                    value: '$_totalMembers',
                    icon: Icons.people_outline,
                    color: AppColors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Recent transactions ─────────────────────────────────────────
            const SectionHeader(
              title: 'Recent Transactions',
              actionLabel: '',
              onAction: null,
            ),
            const SizedBox(height: 14),

            if (_transactions.isEmpty)
              const AppCard(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No transactions yet.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              )
            else
              ..._transactions.map(
                (tx) => _TxTile(tx: tx, formatAmount: _formatAmount),
              ),
          ],
        ),
      );

  void _showAddTransaction(BuildContext ctx) {
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String type = 'deposit';

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (_, setModal) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Transaction',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: type,
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'deposit', child: Text('Deposit')),
                  DropdownMenuItem(
                    value: 'withdrawal',
                    child: Text('Withdrawal'),
                  ),
                ],
                onChanged: (v) => setModal(() => type = v ?? 'deposit'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Amount (FCFA)',
                  prefixIcon: Icon(
                    Icons.currency_exchange,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Add',
                onTap: () async {
                  final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
                  if (amount <= 0 || descCtrl.text.trim().isEmpty) return;
                  Navigator.pop(sheetCtx);
                  await _api.addTransaction(
                    type: type,
                    amount: amount,
                    description: descCtrl.text.trim(),
                  );
                  _load();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  @override
  Widget build(BuildContext context) => AppCard(
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}

class _TxTile extends StatelessWidget {
  final Map<String, dynamic> tx;
  final String Function(num) formatAmount;
  const _TxTile({required this.tx, required this.formatAmount});

  @override
  Widget build(BuildContext context) {
    final type = (tx['type'] as String? ?? '').toLowerCase();
    final isCredit = type == 'deposit';
    final color = isCredit ? AppColors.green : AppColors.red;
    final amount = (tx['amount'] as num? ?? 0);
    final desc = tx['description'] as String? ?? '';
    final date =
        tx['date'] != null ? DateTime.tryParse(tx['date'].toString()) : null;
    final dateStr =
        date != null ? '${date.day}/${date.month}/${date.year}' : '';

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  desc,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$type • $dateStr',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}${formatAmount(amount)}',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
