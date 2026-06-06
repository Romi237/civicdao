import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'screens/app_theme.dart';
import 'navigation/app_routes.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: 'assets/env/.env');
    print('Loaded .env file successfully');
  } catch (e) {
    print('Failed to load .env file: $e');
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://10.0.2.2:3000/api\n');
  }
  await AuthService().init();
  print('AuthService initialized, isLoggedIn: ${AuthService().isLoggedIn}');
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
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRouteGenerator.generateRoute,
    );
  }
}
