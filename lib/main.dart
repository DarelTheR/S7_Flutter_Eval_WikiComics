import 'package:flutter/material.dart';
import 'package:wikiwomics/app_router.dart';
import 'package:wikiwomics/res/app_colors.dart';

void main() { runApp( MyApp());}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: appRouter.routerDelegate,
      routeInformationParser: appRouter.routeInformationParser,
      routeInformationProvider: appRouter.routeInformationProvider,
      title: 'Wikiwomics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.Icone),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.Background,
      ),
    );
  }
}