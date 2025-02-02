import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:wikiwomics/res/app_colors.dart';
import 'package:wikiwomics/res/app_vectorial_images.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({super.key, required this.backgroundColor});

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    int currentTabPosition = _getCurrentTabPosition(location);

    return ClipRRect(
      borderRadius: const BorderRadiusDirectional.only(
        topStart: Radius.circular(30.0),
        topEnd: Radius.circular(30.0),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: backgroundColor,
          indicatorColor: AppColors.Blue_3792FF.withOpacity(0.2),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: AppColors.Blue_3792FF,
                fontWeight: FontWeight.bold,
              );
            }
            return const TextStyle(
              color: AppColors.Icone,
              fontWeight: FontWeight.normal,
            );
          }),
        ),
        child: NavigationBar(
          backgroundColor: backgroundColor,
          surfaceTintColor: backgroundColor,
          selectedIndex: currentTabPosition,
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                context.go('/home');
                break;
              case 1:
                context.go('/comics');
                break;
              case 2:
                context.go('/series');
                break;
              case 3:
                context.go('/movies');
                break;
              case 4:
                context.go('/search');
                break;
            }
          },
          destinations: [
            NavigationDestination(
              icon: SvgPicture.asset(
                AppVectorialImages.navbarHome,
                color: currentTabPosition == 0
                    ? AppColors.Blue_3792FF
                    : AppColors.Icone,
              ),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: SvgPicture.asset(
                AppVectorialImages.navbarComics,
                color: currentTabPosition == 1
                    ? AppColors.Blue_3792FF
                    : AppColors.Icone,
              ),
              label: 'Comics',
            ),
            NavigationDestination(
              icon: SvgPicture.asset(
                AppVectorialImages.navbarSeries,
                color: currentTabPosition == 2
                    ? AppColors.Blue_3792FF
                    : AppColors.Icone,
              ),
              label: 'Séries',
            ),
            NavigationDestination(
              icon: SvgPicture.asset(
                AppVectorialImages.navbarMovies,
                color: currentTabPosition == 3
                    ? AppColors.Blue_3792FF
                    : AppColors.Icone,
              ),
              label: 'Films',
            ),
            NavigationDestination(
              icon: SvgPicture.asset(
                AppVectorialImages.navbarSearch,
                color: currentTabPosition == 4
                    ? AppColors.Blue_3792FF
                    : AppColors.Icone,
              ),
              label: 'Recherche',
            ),
          ],
        ),
      ),
    );
  }

  // Détecte l'onglet actif en fonction de l'URL
  int _getCurrentTabPosition(String location) {
    switch (location) {
      case '/home':
        return 0;
      case '/comics':
        return 1;
      case '/series':
        return 2;
      case '/movies':
        return 3;
      case '/search':
        return 4;
      default:
        return 0;
    }
  }
}
