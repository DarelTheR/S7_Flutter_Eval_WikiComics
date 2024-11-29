import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../res/app_colors.dart';
import '../res/app_vectorial_images.dart';

class CustomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onDestinationSelected;

  const CustomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: AppColors.Bottom_bar,
      destinations: [
        NavigationDestination(
          icon: SvgPicture.asset(AppVectorialImages.navbarHome),
          label: 'Accueil',
        ),
        NavigationDestination(
          icon: SvgPicture.asset(AppVectorialImages.navbarComics),
          label: 'Comics',
        ),
        NavigationDestination(
          icon: SvgPicture.asset(AppVectorialImages.navbarSeries),
          label: 'Séries',
        ),
        NavigationDestination(
          icon: SvgPicture.asset(AppVectorialImages.navbarMovies),
          label: 'Films',
        ),
        NavigationDestination(
          icon: SvgPicture.asset(AppVectorialImages.navbarSearch),
          label: 'Recherche',
        ),
      ],
      selectedIndex: widget.currentIndex,
      onDestinationSelected: widget.onDestinationSelected,
    );
  }
}
