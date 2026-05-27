import 'package:flutter/material.dart';
import '../screens/create_proposal_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/login_screen.dart';
import '../screens/main_shell.dart';
import '../screens/members_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/register_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/vote_detail_screen.dart';
import '../screens/delegate_screen.dart';

class AppRoutes {
  static const login = '/';
  static const forgotPassword = '/forgot-password';
  static const register = '/register';
  static const onboarding = '/onboarding';
  static const mainShell = '/home';
  static const createProposal = '/create-proposal';
  static const notifications = '/notifications';
  static const members = '/members';
  static const voteDetail = '/proposal-detail';
  static const voteSubmitted = '/vote-submitted';
  static const settings = '/settings';
  static const delegate = '/delegate';
}

class AppRouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case AppRoutes.mainShell:
        return MaterialPageRoute(builder: (_) => const MainShell());
      case AppRoutes.createProposal:
        return MaterialPageRoute(builder: (_) => const CreateProposalScreen());
      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case AppRoutes.members:
        return MaterialPageRoute(builder: (_) => const MembersScreen());
      case AppRoutes.voteDetail:
        final args = settings.arguments;
        if (args is Map<String, dynamic> && args.containsKey('proposal')) {
          return MaterialPageRoute(
            builder: (_) => VoteDetailScreen(proposal: args['proposal'] as Map<String, dynamic>),
          );
        }
        return _errorRoute();
      case AppRoutes.voteSubmitted:
        final args = settings.arguments;
        if (args is Map<String, dynamic> && args.containsKey('proposal') && args.containsKey('vote')) {
          return MaterialPageRoute(
            builder: (_) => VoteSubmittedScreen(
              proposal: args['proposal'] as Map<String, dynamic>,
              vote: args['vote'] as String,
            ),
          );
        }
        return _errorRoute();
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.delegate:
        return MaterialPageRoute(builder: (_) => const DelegateScreen());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Page not found',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
