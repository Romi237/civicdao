import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'screens/app_theme.dart';
import 'navigation/app_routes.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: 'assets/env/.env');
  } catch (_) {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://10.0.2.2:3000/api\n');
  }
  await AuthService().init();
  runApp(
    ChangeNotifierProvider<AuthService>(
      create: (_) => AuthService(),
      child: const CivicDaoApp(),
    ),
  );
}

class CivicDaoApp extends StatelessWidget {
  const CivicDaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CivicDAO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute:
          AuthService().isLoggedIn ? AppRoutes.mainShell : AppRoutes.login,
      onGenerateRoute: AppRouteGenerator.generateRoute,
    );
  }
}
