import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wikiwomics/res/app_colors.dart';

import '../res/app_vectorial_images.dart';
import 'components/CustomNavigationBar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.icone),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const MyHomePage(
        title: '',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _tabPosition = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned(
            left: 32,
            top: 34,
            child: Text(
              'Bienvenue !',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            left: 244,
            top: 16,
            child: SvgPicture.asset(
              AppVectorialImages.astronaut,
              width: 121.85,
              height: 159.68,
            ),
          ),
          Positioned.fill(
            top: 200,
            child: Center(
              child: Text(
                'Onglet sélectionné : $_tabPosition',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(
        backgroundColor: AppColors.bottomBar,
        onDestinationSelected: (int position) {
          setState(() {
            _tabPosition = position;
          });
        },
      ),
    );
  }
}
