import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:wikiwomics/components/customNavigationBar.dart';
import 'package:wikiwomics/pages/detail_page.dart';
import 'package:wikiwomics/components/media_card.dart';
import 'package:wikiwomics/res/app_colors.dart';
import 'package:wikiwomics/res/app_vectorial_images.dart';
import '../app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String _apiKey = "91af37aec2e88b4f28ab323c9130d96787c22b2e";
  int _currentTabPosition = 0;

  // Modification de fetchItems pour inclure l'id
  Future<List<Map<String, dynamic>>> fetchItems(String endpoint) async {
    final apiUrl = "https://api.formation-android.fr/comicvine?url=$endpoint&api_key=$_apiKey&format=json";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['results'] as List).map((item) {
          return {
            "id": item["id"],
            "imageUrl": item["image"]?["medium_url"] ?? "",
            "title": item["name"] ?? "Titre inconnu",
          };
        }).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  void _onTabSelected(int position) {
    setState(() {
      _currentTabPosition = position;
    });

    switch (position) {
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
      body: SingleChildScrollView(
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
            _buildSectionWithMore("Séries populaires", "series_list", "Serie", () {
              Navigator.pushNamed(context, AppRoutes.series);
            }),
            _buildSectionWithMore("Comics populaires", "issues", "Comic", () {
              Navigator.pushNamed(context, AppRoutes.comics);
            }),
            _buildSectionWithMore("Films populaires", "movies", "Movie", () {
              Navigator.pushNamed(context, AppRoutes.movies);
            }),
            _buildSectionWithoutMore("Personnages", "characters"),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        backgroundColor: AppColors.Bottom_bar,
        currentTabPosition: _currentTabPosition,
        onDestinationSelected: _onTabSelected,
      ),
    );
  }

  Widget _buildSectionWithMore(
      String title, String endpoint, String mediaType, VoidCallback onMorePressed) {
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
                      fontFamily: 'Nunito',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: onMorePressed,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  backgroundColor: AppColors.Background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  "Voir plus",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildHorizontalList(endpoint, mediaType),
        ],
      ),
    );
  }

  Widget _buildSectionWithoutMore(String title, String endpoint) {
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
            children: [
              const Icon(Icons.circle, size: 8, color: AppColors.Orange),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildHorizontalList(endpoint, "Character"),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(String endpoint, String mediaType) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchItems(endpoint),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 250,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
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
        final items = snapshot.data!.take(5).toList();
        return SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Si le mediaType est défini pour naviguer vers DetailPage
                  if (mediaType == "Serie" ||
                      mediaType == "Comic" ||
                      mediaType == "Movie") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(
                          media: items[index],
                          mediaType: mediaType,
                        ),
                      ),
                    );
                  }
                },
                child: MediaCard(
                  imageUrl: items[index]["imageUrl"]!,
                  title: items[index]["title"]!,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
