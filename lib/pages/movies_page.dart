import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:wikiwomics/components/customNavigationBar.dart';
import 'package:wikiwomics/res/app_colors.dart';
import 'package:wikiwomics/res/app_vectorial_images.dart';

import '../app_routes.dart';
import '../model/movie.dart';
import 'detail_movies.dart';

class MoviesPage extends StatefulWidget {
  const MoviesPage({Key? key}) : super(key: key);

  @override
  _MoviesPageState createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  final List<Movie> _movies = [];
  bool _isLoading = false;
  bool _hasMore = true;

  final String _apiKey = "9423cc1c26178968a90ee233468fd390fd839876";

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  Future<void> _fetchMovies() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.get(Uri.parse(
        "https://comicvine.gamespot.com/api/movies?api_key=$_apiKey&format=json",
      ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final newMovies = (data['results'] as List)
            .map((item) => Movie.fromJson(item))
            .toList();

        if (mounted) {
          setState(() {
            _movies.addAll(newMovies.take(50));
            _hasMore = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _hasMore = false);
        }
      }
    } catch (e) {
      if (mounted) {
        debugPrint("Erreur lors du chargement des films : $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onTabSelected(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.comics);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.series);
        break;
      case 3:
        break;
      case 4:
        Navigator.pushReplacementNamed(context, AppRoutes.search);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (!_isLoading &&
                      _hasMore &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    _fetchMovies();
                  }
                  return false;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _movies.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _movies.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final movie = _movies[index];
                    return _buildMovieCard(movie, index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        backgroundColor: AppColors.bottomBar,
        currentTabPosition: 3,
        onDestinationSelected: _onTabSelected,
      ),
    );
  }

  Widget _buildMovieCard(Movie movie, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailsPage(movieId: movie.id),
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
              color: AppColors.section_1E3243,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    movie.imageUrl,
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
                        movie.title,
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
                        movie.runtime != "Durée inconnue"
                            ? "Durée : ${movie.runtime} minutes"
                            : "Durée inconnue",
                      ),
                      _buildInfoRow(
                        AppVectorialImages.icCalendarBicolor,
                        movie.releaseYear,
                      ),
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
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
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
          color: AppColors.icone,
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
