import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';

class CreateProposalScreen extends StatefulWidget {
  const CreateProposalScreen({super.key});
  @override
  State<CreateProposalScreen> createState() => _CreateProposalScreenState();
}

class _CreateProposalScreenState extends State<CreateProposalScreen> {
  final _api = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();

  List<String> _categories = [
    'General',
    'Infrastructure',
    'Education',
    'Health',
    'Environment',
    'Finance',
    'Social',
    'Technology',
  ];
  String _category = 'General';
  DateTime? _endDate;
  bool _loading = false;
  bool _loadingCategories = true;
  String _error = '';
  String _loadError = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final result = await _api.getProposalCategories();
    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _categories = (result['categories'] as List).cast<String>();
        _category = _categories.isNotEmpty ? _categories.first : _category;
        _loadingCategories = false;
      });
    } else {
      setState(() {
        _loadError = result['error'] ?? 'Unable to load categories.';
        _loadingCategories = false;
      });
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.purple),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = '';
    });

    final result = await _api.createProposal(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      requestedBudget: double.parse(_budgetCtrl.text.trim()),
      voteEndDate: _endDate,
      category: _category,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proposal submitted successfully!'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true); // tells the caller to refresh
    } else {
      setState(() => _error = result['error'] ?? 'Submission failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('New Proposal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Proposal Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Fill in the details. An admin will review and open it for voting.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),

              if (_loadError.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _loadError,
                          style: const TextStyle(
                            color: AppColors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _loadCategories,
                        child: const Text(
                          'Retry',
                          style: TextStyle(
                            color: AppColors.purple,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (_error.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _error,
                    style: const TextStyle(color: AppColors.red, fontSize: 13),
                  ),
                ),
              ],

              // Title
              TextFormField(
                controller: _titleCtrl,
                style: const TextStyle(color: Colors.white),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Title is required';
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Short, clear title for your proposal',
                ),
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                controller: _descCtrl,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Explain the problem and your proposed solution…',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),

              // Budget
              TextFormField(
                controller: _budgetCtrl,
                style: const TextStyle(color: Colors.white),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Budget is required';
                  }
                  final n = double.tryParse(v.trim());
                  if (n == null) {
                    return 'Enter a valid number';
                  }
                  if (n <= 0) {
                    return 'Budget must be greater than zero';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Requested Budget (FCFA)',
                  hintText: '0.00',
                  prefixIcon: Icon(
                    Icons.currency_exchange,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              if (_loadingCategories)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v ?? 'General'),
                ),
              const SizedBox(height: 12),

              // Vote end date
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_outlined,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _endDate == null
                              ? 'Voting deadline (optional)'
                              : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                          style: TextStyle(
                            color: _endDate == null
                                ? AppColors.textMuted
                                : Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (_endDate != null)
                        GestureDetector(
                          onTap: () => setState(() => _endDate = null),
                          child: const Icon(
                            Icons.close,
                            color: AppColors.textMuted,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.purple),
                    )
                  : PrimaryButton(label: 'Submit Proposal', onTap: _submit),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
