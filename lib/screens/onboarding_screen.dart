import 'package:flutter/material.dart';
import '../navigation/app_routes.dart';
import '../services/api_service.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _api = ApiService();
  int _step = 0;
  String? _selectedRole;
  final List<String> _interests = [];
  List<Map<String, dynamic>> _roles = [];
  List<String> _interestOptions = [];
  bool _loadingOptions = true;
  String _loadError = '';

  static const _steps = ['Welcome', 'Your role', 'Interests', 'Ready!'];
  static const _defaultRoles = [
    {
      'icon': Icons.person_outline_rounded,
      'title': 'Regular member',
      'desc': 'I vote on proposals and participate',
      'color': AppColors.purple,
    },
    {
      'icon': Icons.star_outline_rounded,
      'title': 'Council member',
      'desc': 'I help govern and create proposals',
      'color': AppColors.amber,
    },
    {
      'icon': Icons.visibility_outlined,
      'title': 'Observer',
      'desc': 'I monitor activity without voting',
      'color': AppColors.green,
    },
  ];

  static const _defaultInterestOptions = [
    'Treasury',
    'Governance',
    'Events',
    'Partnerships',
    'Technical',
    'Community',
  ];

  @override
  void initState() {
    super.initState();
    _loadOnboardingOptions();
  }

  Future<void> _loadOnboardingOptions() async {
    setState(() {
      _loadingOptions = true;
      _loadError = '';
    });

    final result = await _api.getOnboardingOptions();
    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _roles = (result['roles'] as List).map((e) {
          final raw = Map<String, dynamic>.from(e as Map);
          return {
            'icon': _iconFromName(raw['icon'] as String),
            'title': raw['title'] as String,
            'desc': raw['desc'] as String,
            'color': raw['color'] is int
                ? Color(raw['color'] as int)
                : AppColors.purple,
          };
        }).toList();
        _interestOptions = (result['interests'] as List).cast<String>();
        _loadingOptions = false;
      });
    } else {
      setState(() {
        _loadError = result['error'] ?? 'Failed to load onboarding options.';
        _roles = _defaultRoles;
        _interestOptions = _defaultInterestOptions;
        _loadingOptions = false;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    if (_selectedRole == null) {
      setState(() {
        _loadError = 'Please choose a role before continuing.';
      });
      return;
    }

    setState(() {
      _loadingOptions = true;
      _loadError = '';
    });

    final result = await _api.completeOnboarding(
      role: _selectedRole!,
      interests: _interests,
    );
    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
    } else {
      setState(() {
        _loadingOptions = false;
        _loadError = result['error'] ?? 'Failed to complete onboarding.';
      });
    }
  }

  IconData _iconFromName(String name) {
    switch (name) {
      case 'person_outline_rounded':
        return Icons.person_outline_rounded;
      case 'star_outline_rounded':
        return Icons.star_outline_rounded;
      case 'visibility_outlined':
        return Icons.visibility_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Progress dots
              Row(
                children: List.generate(
                  _steps.length,
                  (i) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        right: i < _steps.length - 1 ? 5 : 0,
                      ),
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= _step ? AppColors.purple : AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Step ${_step + 1} of ${_steps.length}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(child: _buildStep()),
              const SizedBox(height: 20),
              if (_loadError.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 26),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.red.withValues(alpha: 76)),
                  ),
                  child: Text(
                    _loadError,
                    style: const TextStyle(color: AppColors.red, fontSize: 13),
                  ),
                ),
              PrimaryButton(
                label: _step < _steps.length - 1 ? 'Continue' : 'Get started',
                onTap: () {
                  if (_step < _steps.length - 1) {
                    if (_step == 1 && _selectedRole == null) {
                      setState(() {
                        _loadError = 'Please select a role to continue.';
                      });
                      return;
                    }
                    setState(() => _step++);
                  } else {
                    _completeOnboarding();
                  }
                },
              ),
              const SizedBox(height: 10),
              if (_step > 0)
                OutlineButton2(
                  label: 'Skip for now',
                  onTap: () {
                    if (_step < _steps.length - 1) {
                      setState(() => _step++);
                    } else {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.mainShell,
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    if ((_step == 1 || _step == 2) && _loadingOptions) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.purple),
      );
    }

    switch (_step) {
      case 0:
        return _welcomeStep();
      case 1:
        return _roleStep();
      case 2:
        return _interestsStep();
      case 3:
        return _readyStep();
      default:
        return const SizedBox();
    }
  }

  Widget _welcomeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3730A3), AppColors.purple],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.how_to_vote_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "Welcome to CivicDAO",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "You're joining a community that makes decisions together. Here's what you can do:",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        _featureRow(
          Icons.how_to_vote_outlined,
          AppColors.purple,
          'Vote on proposals',
          'Your tokens = your voice',
        ),
        const SizedBox(height: 16),
        _featureRow(
          Icons.account_balance_wallet_outlined,
          AppColors.green,
          'Track the treasury',
          'Full financial transparency',
        ),
        const SizedBox(height: 16),
        _featureRow(
          Icons.people_outline_rounded,
          AppColors.amber,
          'Meet your members',
          'See who governs alongside you',
        ),
      ],
    );
  }

  Widget _roleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "What's your role in this DAO?",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'This helps us personalize your experience.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 24),
        ..._roles.map((r) {
          final selected = _selectedRole == r['title'];
          return GestureDetector(
            onTap: () => setState(() => _selectedRole = r['title'] as String),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? AppColors.purple
                      : AppColors.border.withValues(alpha: 128),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (r['color'] as Color).withValues(alpha: 38),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      r['icon'] as IconData,
                      color: r['color'] as Color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          r['desc'] as String,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: AppColors.purple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _interestsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "What topics interest you?",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Get notified about proposals that matter to you.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _interestOptions.map((t) {
            final sel = _interests.contains(t);
            return GestureDetector(
              onTap: () => setState(() {
                sel ? _interests.remove(t) : _interests.add(t);
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: sel
                      ? AppColors.purple.withValues(alpha: 51)
                      : AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: sel
                        ? AppColors.purple.withValues(alpha: 128)
                        : AppColors.border,
                  ),
                ),
                child: Text(
                  t,
                  style: TextStyle(
                    color: sel ? AppColors.purple : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _readyStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.green.withValues(alpha: 38),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.green,
            size: 50,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "You're all set!",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Your account is ready. Start exploring proposals and cast your first vote.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _featureRow(IconData icon, Color color, String title, String sub) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 38),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Column(
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
              sub,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
