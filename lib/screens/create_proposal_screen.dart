import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';

class CreateProposalScreen extends StatefulWidget {
  const CreateProposalScreen({super.key});
  @override
  State<CreateProposalScreen> createState() => _CreateProposalScreenState();
}

class _CreateProposalScreenState extends State<CreateProposalScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _category = 'Treasury';
  int _duration = 3;
  bool _submitted = false;

  final _categories = ['Treasury', 'Governance', 'Partnership', 'Technical', 'Community'];
  final _durations = [3, 5, 7, 14];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('New proposal'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Preview', style: TextStyle(color: AppColors.purple, fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
      body: _submitted ? _successView() : _formView(),
    );
  }

  Widget _formView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('Title'),
        TextField(controller: _titleCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Proposal title...')),
        const SizedBox(height: 16),
        _label('Category'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: _categories.map((c) => GestureDetector(
            onTap: () => setState(() => _category = c),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _category == c ? AppColors.purple.withValues(alpha: 0.2) : AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _category == c ? AppColors.purple.withValues(alpha: 0.5) : AppColors.border),
              ),
              child: Text(c, style: TextStyle(color: _category == c ? AppColors.purple : AppColors.textSecondary, fontSize: 13, fontWeight: _category == c ? FontWeight.w600 : FontWeight.normal)),
            ),
          )).toList()),
        ),
        const SizedBox(height: 16),
        _label('Description'),
        TextField(
          controller: _descCtrl,
          maxLines: 5,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'Describe your proposal in detail...', alignLabelWithHint: true),
        ),
        const SizedBox(height: 16),
        _label('Funding request (optional)'),
        TextField(
          controller: _amountCtrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          decoration: const InputDecoration(hintText: '0', prefixText: 'CIVIC  ', prefixStyle: TextStyle(color: AppColors.textMuted)),
        ),
        const SizedBox(height: 16),
        _label('Voting duration'),
        Row(children: _durations.map((d) {
          final sel = _duration == d;
          return Expanded(child: GestureDetector(
            onTap: () => setState(() => _duration = d),
            child: Container(
              margin: EdgeInsets.only(right: d != _durations.last ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: sel ? AppColors.purple.withValues(alpha: 0.2) : AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: sel ? AppColors.purple.withValues(alpha: 0.5) : AppColors.border),
              ),
              child: Column(children: [
                Text('${d}d', style: TextStyle(color: sel ? AppColors.purple : AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.w600)),
                Text(d == 1 ? '1 day' : '$d days', style: TextStyle(color: sel ? AppColors.purple.withValues(alpha: 0.8) : AppColors.textMuted, fontSize: 10)),
              ]),
            ),
          ));
        }).toList()),
        const SizedBox(height: 18),
        const AppCard(
          child: Row(children: [
            Icon(Icons.info_outline_rounded, color: AppColors.amber, size: 18),
            SizedBox(width: 10),
            Expanded(child: Text('This proposal requires 51% quorum to pass. You need 100 CIVIC minimum to submit.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5))),
          ]),
        ),
        const SizedBox(height: 20),
        PrimaryButton(label: 'Submit proposal', onTap: () => setState(() => _submitted = true)),
        const SizedBox(height: 30),
      ]),
    );
  }

  Widget _successView() {
    return Center(
      child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.15), shape: BoxShape.circle), child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.green, size: 48)),
        const SizedBox(height: 24),
        const Text('Proposal submitted!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text('Your proposal is now under review. Voting will open once the council approves it.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6)),
        const SizedBox(height: 32),
        PrimaryButton(label: 'Back to proposals', onTap: () => Navigator.pop(context)),
      ])),
    );
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(t, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)));
}


