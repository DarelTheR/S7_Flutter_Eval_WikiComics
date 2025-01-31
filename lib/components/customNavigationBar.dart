import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wikiwomics/res/app_colors.dart';

import '../res/app_vectorial_images.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({
    super.key,
    required this.backgroundColor,
    required this.currentTabPosition,
    required this.onDestinationSelected,
  });

  final Color backgroundColor;
  final int currentTabPosition;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadiusDirectional.only(
        topStart: Radius.circular(30.0),
        topEnd: Radius.circular(30.0),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: backgroundColor,
          indicatorColor: AppColors.blue_3792FF.withOpacity(0.2),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const TextStyle(
                color: AppColors.blue_3792FF,
                fontWeight: FontWeight.bold,
              );
            }
            return const TextStyle(
              color: AppColors.icone,
              fontWeight: FontWeight.normal,
            );
          }),
        ),
        child: NavigationBar(
          backgroundColor: backgroundColor,
          surfaceTintColor: backgroundColor,
          destinations: [
            NavigationDestination(
              icon: SvgPicture.asset(
                AppVectorialImages.navbarHome,
                color: currentTabPosition == 0
                    ? AppColors.blue_3792FF
                    : AppColors.icone,
              ),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: SvgPicture.asset(
                AppVectorialImages.navbarComics,
                color: currentTabPosition == 1
                    ? AppColors.blue_3792FF
                    : AppColors.icone,
              ),
              label: 'Comics',
            ),
            NavigationDestination(
              icon: SvgPicture.asset(
                AppVectorialImages.navbarSeries,
                color: currentTabPosition == 2
                    ? AppColors.blue_3792FF
                    : AppColors.icone,
              ),
              label: 'Séries',
            ),
            NavigationDestination(
              icon: SvgPicture.asset(
                AppVectorialImages.navbarMovies,
                color: currentTabPosition == 3
                    ? AppColors.blue_3792FF
                    : AppColors.icone,
              ),
              label: 'Films',
            ),
            NavigationDestination(
              icon: SvgPicture.asset(
                AppVectorialImages.navbarSearch,
                color: currentTabPosition == 4
                    ? AppColors.blue_3792FF
                    : AppColors.icone,
              ),
              label: 'Recherche',
            ),
          ],
          selectedIndex: currentTabPosition,
          onDestinationSelected: onDestinationSelected,
        ),
      ),
    );
  }
}
