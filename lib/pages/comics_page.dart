// lib/pages/comics_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wikiwomics/bloc/Comics_bloc/comics_bloc.dart';
import 'package:wikiwomics/components/customNavigationBar.dart';
import 'package:wikiwomics/res/app_colors.dart';
import 'package:wikiwomics/pages/detail_page.dart';
import 'package:wikiwomics/res/app_vectorial_images.dart';
import '../app_routes.dart';

class ComicsPage extends StatelessWidget {
  const ComicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ComicsBloc()..add(FetchComics()),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Comics les plus populaires",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<ComicsBloc, ComicsState>(
                  builder: (context, state) {
                    if (state is ComicsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ComicsLoaded) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: state.comics.length,
                        itemBuilder: (context, index) {
                          final comic = state.comics[index];
                          return _buildComicCard(comic, index, context);
                        },
                      );
                    } else if (state is ComicsError) {
                      return Center(child: Text(state.message));
                    }
                    return Container();
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomNavigationBar(
          backgroundColor: AppColors.Bottom_bar,
          currentTabPosition: 1,
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, AppRoutes.home);
                break;
              case 1:
                break;
              case 2:
                Navigator.pushReplacementNamed(context, AppRoutes.series);
                break;
              case 3:
                Navigator.pushReplacementNamed(context, AppRoutes.movies);
                break;
              case 4:
                Navigator.pushReplacementNamed(context, AppRoutes.search);
                break;
            }
          },
        ),
      ),
    );
  }

  Widget _buildComicCard(Map<String, dynamic> comic, int index, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(media: comic, mediaType: "Comic"),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            padding: const EdgeInsets.all(16.0),
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.Section_1E3243,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    comic['imageUrl'],
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      size: 120,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        comic['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                          AppVectorialImages.icPublisherBicolor, comic['studio']),
                      _buildInfoRow(AppVectorialImages.icTvBicolor,
                          "Édition : ${comic['issueNumber']}"),
                      _buildInfoRow(AppVectorialImages.icCalendarBicolor,
                          comic['releaseDate']),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                "#${index + 1}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildInfoRow(String iconPath, String info) {
    return Row(
      children: [
        SvgPicture.asset(
          iconPath,
          width: 16,
          height: 16,
          color: AppColors.Icone,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            info,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}