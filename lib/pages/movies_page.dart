import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wikiwomics/bloc/Movies_bloc/movies_bloc.dart';
import 'package:wikiwomics/components/customNavigationBar.dart';
import 'package:wikiwomics/res/app_colors.dart';
import 'package:wikiwomics/res/app_vectorial_images.dart';

import '../app_routes.dart';

class MoviesPage extends StatelessWidget {
  const MoviesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MoviesBloc()..add(FetchMovies()),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Films les plus populaires",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<MoviesBloc, MoviesState>(
                  builder: (context, state) {
                    if (state is MoviesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is MoviesLoaded) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: state.movies.length > 50 ? 50 : state.movies.length, // on limite a 50
                        itemBuilder: (context, index) {
                          final movie = state.movies[index];
                          return _buildMovieCard(movie, index, context);
                        },
                      );
                    } else if (state is MoviesError) {
                      return Center(child: Text(state.message));
                    }
                    return Container();
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const CustomNavigationBar(
          backgroundColor: AppColors.Bottom_bar,
        ),
      ),
    );
  }

  Widget _buildMovieCard(Map<String, dynamic> movie, int index, BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          AppRoutes.detail,
          extra: {
            'media': movie,
            'mediaType': 'Movie',
          },
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
                    movie['imageUrl'],
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
                        movie['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        AppVectorialImages.icTvBicolor,
                        movie['runtime'] != "Durée inconnue"
                            ? "Durée : ${movie['runtime']} minutes"
                            : "Durée inconnue",
                      ),
                      _buildInfoRow(AppVectorialImages.icCalendarBicolor, movie['releaseDate']),
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

  /// Ajout de _buildInfoRow pour éviter l'erreur
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
