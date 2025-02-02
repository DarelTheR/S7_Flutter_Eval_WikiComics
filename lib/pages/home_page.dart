import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:wikiwomics/app_routes.dart';
import 'package:wikiwomics/bloc/Home_bloc/home_bloc.dart';
import 'package:wikiwomics/components/customNavigationBar.dart';
import 'package:wikiwomics/components/media_card.dart';
import 'package:wikiwomics/res/app_colors.dart';
import 'package:wikiwomics/res/app_vectorial_images.dart';

import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(FetchHomeData()),
      child: Scaffold(
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HomeLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        const Text(
                          'Bienvenue !',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        SvgPicture.asset(
                          AppVectorialImages.astronaut,
                          width: 64,
                          height: 64,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildSectionWithMore("Séries populaires", state.series,
                        "Serie", AppRoutes.series),
                    _buildSectionWithMore("Comics populaires", state.comics,
                        "Comic", AppRoutes.comics),
                    _buildSectionWithMore("Films populaires", state.movies,
                        "Movie", AppRoutes.movies),
                    _buildSectionWithoutMore(
                        "Personnages", state.characters, "Character"),
                  ],
                ),
              );
            } else if (state is HomeError) {
              return Center(
                child: Text(
                  "Erreur : ${state.message}",
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        bottomNavigationBar: const CustomNavigationBar(
          backgroundColor: AppColors.Bottom_bar,
        ),
      ),
    );
  }

  Widget _buildHorizontalList(
      List<Map<String, dynamic>> items, String mediaType) {
    if (items.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Center(
          child: Text(
            "Aucune donnée disponible",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailPage(
                    media: items[index],
                    mediaType: mediaType,
                  ),
                ),
              );
            },
            child: MediaCard(
              imageUrl: items[index]["imageUrl"],
              title: items[index]["title"],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionWithMore(String title, List<Map<String, dynamic>> items,
      String mediaType, String route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.Section_1E3243,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  context.push(route);
                },
                child: const Text(
                  "Voir plus",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Nunito'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildHorizontalList(items, mediaType),
        ],
      ),
    );
  }

  Widget _buildSectionWithoutMore(
      String title, List<Map<String, dynamic>> items, String mediaType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        _buildHorizontalList(items, mediaType),
      ],
    );
  }
}
