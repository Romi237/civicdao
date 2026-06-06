import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/proposals_screen.dart';
import '../screens/vote_detail_screen.dart';
import '../screens/treasury_screen.dart';
import '../screens/members_screen.dart';
import '../screens/create_proposal_screen.dart';
import '../screens/delegate_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/admin_screen.dart';
import '../services/auth_service.dart';

/// All named routes in one place — easy to find and modify.
class AppRoutes {
  static const String login = '/';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String forgotPassword = '/forgot-password';
  static const String mainShell = '/home';
  static const String proposals = '/proposals';
  static const String voteDetail = '/vote-detail';
  static const String voteSubmitted = '/vote-submitted';
  static const String treasury = '/treasury';
  static const String members = '/members';
  static const String delegate = '/delegate';
  static const String createProposal = '/create-proposal';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String admin = '/admin';
}

class AppRouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return _slide(const LoginScreen());

      case AppRoutes.register:
        return _slide(const RegisterScreen());

      case AppRoutes.mainShell:
        return _authRoute(const MainShellScreen());

      case AppRoutes.proposals:
        return _authRoute(const ProposalsScreen());

      case AppRoutes.voteDetail:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final proposal = args['proposal'] as Map<String, dynamic>? ?? {};
        final proposalId = args['proposalId'] as String? ?? '';
        return _authRoute(VoteDetailScreen(
          proposal: proposal,
          proposalId: proposalId,
        ));

      case AppRoutes.voteSubmitted:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _authRoute(VoteSubmittedScreen(args: args));

      case AppRoutes.onboarding:
        return _authRoute(const OnboardingScreen());

      case AppRoutes.treasury:
        return _authRoute(const TreasuryScreen());

      case AppRoutes.members:
        return _authRoute(const MembersScreen());

      case AppRoutes.delegate:
        return _authRoute(const DelegateScreen());

      case AppRoutes.createProposal:
        return _authRoute(const CreateProposalScreen());

      case AppRoutes.notifications:
        return _authRoute(const NotificationsScreen());

      case AppRoutes.profile:
        return _authRoute(const ProfileScreen());

      case AppRoutes.settings:
        return _authRoute(const SettingsScreen());

      case AppRoutes.admin:
        return _authRoute(const AdminScreen());

      case AppRoutes.forgotPassword:
        return _slide(const _Placeholder('Forgot Password'));

      default:
        return _slide(const _Placeholder('Page not found'));
    }
  }

  static Route<dynamic> _authRoute(Widget page) =>
      _slide(AuthGuard(child: page));

  static PageRouteBuilder _slide(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 250),
      );
}

class AuthGuard extends StatelessWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }
    return child;
  }
}

// ── Main shell with bottom navigation ──────────────────────────────────────
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});
  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _idx = 0;

  static const _screens = [
    DashboardScreen(),
    ProposalsScreen(),
    TreasuryScreen(),
    MembersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(index: _idx, children: _screens),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _idx,
          onDestinationSelected: (i) => setState(() => _idx = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.how_to_vote_outlined),
              selectedIcon: Icon(Icons.how_to_vote),
              label: 'Proposals',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet),
              label: 'Treasury',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'Members',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      );
}

// ── Vote submitted success screen ──────────────────────────────────────────
class VoteSubmittedScreen extends StatelessWidget {
  final Map<String, dynamic> args;
  const VoteSubmittedScreen({super.key, required this.args});
  @override
  Widget build(BuildContext context) {
    final vote = args['vote'] as String? ?? 'for';
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: (vote == 'for'
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFEF4444))
                      .withValues(alpha: 38),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  vote == 'for' ? Icons.thumb_up : Icons.thumb_down,
                  color: vote == 'for'
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFEF4444),
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              const Text('Vote Submitted!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                  'You voted ${vote == 'for' ? 'For' : 'Against'} this proposal.',
                  style:
                      const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.mainShell, (_) => false),
                  child: const Text('Back to Home'),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Placeholder for screens not yet built ──────────────────────────────────
class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder(this.title);
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Text('$title — coming soon',
              style: const TextStyle(color: Color(0xFF94A3B8))),
        ),
      );
}
