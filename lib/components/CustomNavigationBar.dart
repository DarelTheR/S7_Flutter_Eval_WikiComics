import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wikiwomics/res/app_colors.dart';

import '../res/app_vectorial_images.dart';

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({
    super.key,
    required this.backgroundColor,
    required this.onDestinationSelected,
  });

  final Color backgroundColor;
  final ValueChanged<int> onDestinationSelected;

  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int _tabPosition = 0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadiusDirectional.only(
        topStart: Radius.circular(30.0),
        topEnd: Radius.circular(30.0),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: widget.backgroundColor,
          indicatorColor: AppColors.blue_3792FF.withOpacity(0.2),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
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
          backgroundColor: widget.backgroundColor,
          surfaceTintColor: widget.backgroundColor,
          destinations: [
            NavigationDestination(
              icon: SvgPicture.asset(
                AppVectorialImages.navbarHome,
                color:
                    _tabPosition == 0 ? AppColors.blue_3792FF : AppColors.icone,
              ),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: SvgPicture.asset(
                AppVectorialImages.navbarComics,
                color:
                    _tabPosition == 1 ? AppColors.blue_3792FF : AppColors.icone,
              ),
              label: 'Comics',
            ),
            NavigationDestination(
              icon: SvgPicture.asset(
                AppVectorialImages.navbarSeries,
                color:
                    _tabPosition == 2 ? AppColors.blue_3792FF : AppColors.icone,
              ),
              label: 'Séries',
            ),
            NavigationDestination(
              icon: SvgPicture.asset(
                AppVectorialImages.navbarMovies,
                color:
                    _tabPosition == 3 ? AppColors.blue_3792FF : AppColors.icone,
              ),
              label: 'Films',
            ),
            NavigationDestination(
              icon: SvgPicture.asset(
                AppVectorialImages.navbarSearch,
                color:
                    _tabPosition == 4 ? AppColors.blue_3792FF : AppColors.icone,
              ),
              label: 'Recherche',
            ),
          ],
          selectedIndex: _tabPosition,
          onDestinationSelected: (int position) {
            setState(() {
              _tabPosition = position;
            });
            widget.onDestinationSelected(position);
          },
        ),
      ),
    );
  }
}
