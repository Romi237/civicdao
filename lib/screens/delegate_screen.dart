import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';

class DelegateScreen extends StatefulWidget {
  const DelegateScreen({super.key});
  @override
  State<DelegateScreen> createState() => _DelegateScreenState();
}

class _DelegateScreenState extends State<DelegateScreen> {
  final _api = ApiService();
  List<Map<String, dynamic>> _delegates = [];
  String? _delegatedId;
  String? _delegatedName;
  bool _loading = true;
  String _error = '';
  int _votingPower = 1250;

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

    final result = await _api.getDelegates();
    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _delegates = (result['delegates'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _delegatedId = result['delegatedTo']?.toString();
        _delegatedName = result['currentDelegateName'] as String?;
        _votingPower = (result['votingPower'] as num?)?.toInt() ?? 1250;
        _loading = false;
      });
    } else {
      setState(() {
        _error = result['error'] ?? 'Failed to load delegates.';
        _loading = false;
      });
    }
  }

  Future<void> _delegate(String id, String name) async {
    final result = await _api.delegate(id);
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() {
        _delegatedId = id;
        _delegatedName = name;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Votes delegated to $name'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Failed to delegate.'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _revokeDelegation() async {
    final result = await _api.revokeDelegation();
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() {
        _delegatedId = null;
        _delegatedName = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Delegation removed'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _load();
    }
  }

  String _formatPower(int value) {
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)},000 CIVIC';
    return '$value CIVIC';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Delegate votes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3730A3), AppColors.purple],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your voting power',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatPower(_votingPower),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _delegatedName == null
                                  ? 'Currently not delegated'
                                  : 'Delegated to $_delegatedName',
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'How delegation works',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const _Step(
                        num: '1',
                        title: 'Choose a delegate',
                        desc: 'Pick a trusted member to vote on your behalf.',
                      ),
                      const _Step(
                        num: '2',
                        title: 'Set the scope',
                        desc: 'All proposals, or specific categories only.',
                      ),
                      const _Step(
                        num: '3',
                        title: 'Revoke anytime',
                        desc: 'You can take back your votes at any time.',
                        last: true,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Top delegates',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      AppCard(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 16,
                        ),
                        child: Column(
                          children: _delegates.asMap().entries.map((e) {
                            final d = e.value;
                            final isLast = e.key == _delegates.length - 1;
                            final isDelegated =
                                _delegatedId == d['_id'].toString();
                            return Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 13),
                                  child: Row(
                                    children: [
                                      UserAvatar(
                                        initials: d['initials'] as String,
                                        color: Color(
                                          (d['color'] as int?) ?? 0xFF8B5CF6,
                                        ),
                                        size: 42,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              d['name'] as String,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              '${d['participation']} participation · ${d['delegators']} delegator${(d['delegators'] as int) != 1 ? 's' : ''}',
                                              style: const TextStyle(
                                                color: AppColors.textMuted,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => _delegate(
                                          d['_id'].toString(),
                                          d['name'] as String,
                                        ),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDelegated
                                                ? AppColors.green.withValues(
                                                    alpha: 0.2,
                                                  )
                                                : AppColors.purple.withValues(
                                                    alpha: 0.15,
                                                  ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: isDelegated
                                                  ? AppColors.green.withValues(
                                                      alpha: 0.4,
                                                    )
                                                  : AppColors.purple.withValues(
                                                      alpha: 0.3,
                                                    ),
                                            ),
                                          ),
                                          child: Text(
                                            isDelegated
                                                ? '✓ Delegated'
                                                : 'Delegate',
                                            style: TextStyle(
                                              color: isDelegated
                                                  ? AppColors.green
                                                  : AppColors.purple,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isLast)
                                  const Divider(
                                      color: AppColors.border, height: 1),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_delegatedId != null)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _revokeDelegation,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.red,
                              side: const BorderSide(color: AppColors.red),
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Remove delegation'),
                          ),
                        ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }
}

class _Step extends StatelessWidget {
  final String num, title, desc;
  final bool last;
  const _Step({
    required this.num,
    required this.title,
    required this.desc,
    this.last = false,
  });
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.purple,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    num,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      desc,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!last)
            Padding(
              padding: const EdgeInsets.only(left: 13, top: 3, bottom: 3),
              child: Container(width: 2, height: 22, color: AppColors.border),
            ),
        ],
      );
}
