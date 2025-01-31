import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:wikiwomics/components/customNavigationBar.dart';
import 'package:wikiwomics/res/app_colors.dart';
import 'package:wikiwomics/res/app_vectorial_images.dart';

import '../app_routes.dart';
import '../model/comic.dart';
import 'detail_comics.dart';

class ComicsPage extends StatefulWidget {
  const ComicsPage({super.key});
  @override
  _ComicsPageState createState() => _ComicsPageState();
}

class _ComicsPageState extends State<ComicsPage> {
  final List<Comic> _comics = [];
  bool _isLoading = false;
  bool _hasMore = true;

  final String _apiKey = "91af37aec2e88b4f28ab323c9130d96787c22b2e";

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', '').then((_) {
      _fetchComics();
    });
  }

  Future<void> _fetchComics() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.get(Uri.parse(
          "https://comicvine.gamespot.com/api/issues?api_key=$_apiKey&format=json"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final newComics = (data['results'] as List)
            .map((item) => Comic.fromJson(item))
            .toList();

        if (mounted) {
          setState(() {
            _comics.addAll(newComics.take(50));
            _hasMore = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _hasMore = false);
        }
      }
    } catch (e) {
      debugPrint("Erreur lors du chargement des comics : $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onTabSelected(int index) {
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
                "Comics les plus populaires",
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
                    _fetchComics();
                  }
                  return false;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _comics.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _comics.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final comic = _comics[index];
                    return _buildComicCard(comic, index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        backgroundColor: AppColors.bottomBar,
        currentTabPosition: 1,
        onDestinationSelected: _onTabSelected,
      ),
    );
  }

  Widget _buildComicCard(Comic comic, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ComicDetailsPage(comicId: comic.id),
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
                    comic.imageUrl,
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
                        comic.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(AppVectorialImages.icBooksBicolor,
                          "N° ${comic.issueNumber}"),
                      _buildInfoRow(AppVectorialImages.icCalendarBicolor,
                          comic.releaseDate),
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
