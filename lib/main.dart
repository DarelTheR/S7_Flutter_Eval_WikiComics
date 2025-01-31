import 'package:flutter/material.dart';
import 'package:wikiwomics/res/app_colors.dart';

import 'app_routes.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wikiwomics',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.icone),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
      ),
      onGenerateRoute: AppRoutes.generateRoute,
      initialRoute: AppRoutes.home,
    );
  }
}
