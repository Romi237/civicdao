import 'package:flutter/material.dart';
import 'app_theme.dart';
import '../navigation/app_routes.dart';

void main() {
  runApp(const CivicDaoApp());
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

