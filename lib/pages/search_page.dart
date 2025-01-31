import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:wikiwomics/components/customNavigationBar.dart';
import 'package:wikiwomics/components/media_card.dart';
import 'package:wikiwomics/res/app_colors.dart';
import 'package:wikiwomics/res/app_vectorial_images.dart';

import '../app_routes.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _hasSearched = false;
  String _query = "";
  List<Map<String, dynamic>> _seriesResults = [];
  List<Map<String, dynamic>> _comicsResults = [];
  List<Map<String, dynamic>> _moviesResults = [];
  List<Map<String, dynamic>> _charactersResults = [];

  final String _apiKey = "9423cc1c26178968a90ee233468fd390fd839876";

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('la recherche ne peut pas être vide')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _query = query;
      _seriesResults.clear();
      _comicsResults.clear();
      _moviesResults.clear();
      _charactersResults.clear();
    });

    try {
      await Future.wait([
        _fetchResults("https://comicvine.gamespot.com/api/series_list", query,
            _seriesResults),
        _fetchResults(
            "https://comicvine.gamespot.com/api/issues", query, _comicsResults),
        _fetchResults(
            "https://comicvine.gamespot.com/api/movies", query, _moviesResults),
        _fetchResults("https://comicvine.gamespot.com/api/characters", query,
            _charactersResults),
      ]);
    } catch (e) {
      debugPrint("Erreur lors de la recherche : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la recherche')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchResults(
      String url, String query, List<Map<String, dynamic>> targetList) async {
    final response = await http
        .get(Uri.parse("$url?api_key=$_apiKey&format=json&filter=name:$query"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = (data['results'] as List).map((item) {
        return {
          "imageUrl":
              item["image"]?["medium_url"] ?? "https://via.placeholder.com/150",
          "title": item["name"] ?? "Titre inconnu",
        };
      }).toList();
      targetList.addAll(results);
    } else {
      debugPrint("Erreur API pour $url");
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
        Navigator.pushReplacementNamed(context, AppRoutes.movies);
        break;
      case 4:
        Navigator.pushReplacementNamed(context, AppRoutes.search);
        break;
    }
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> results) {
    return results.isEmpty
        ? const SizedBox.shrink()
        : Container(
            margin: const EdgeInsets.only(bottom: 32.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.section_1E3243,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 8),
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      return MediaCard(
                        imageUrl: results[index]["imageUrl"]!,
                        title: results[index]["title"]!,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildInitialMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AppVectorialImages.astronaut,
            height: 100,
            width: 100,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Saisissez une recherche pour trouver un",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "comics, film, série ou personnage.",
                  style: TextStyle(
                    color: Colors.lightBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.section_1E3243,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recherche",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Comic, film, série...",
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      onSubmitted: (value) => _performSearch(value),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            AppVectorialImages.astronaut,
                            height: 80,
                            width: 80,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Recherche en cours \nMerci de patienter...",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : !_hasSearched
                      ? _buildInitialMessage()
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildSection("Séries", _seriesResults),
                              _buildSection("Comics", _comicsResults),
                              _buildSection("Films", _moviesResults),
                              _buildSection("Personnage", _charactersResults),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        backgroundColor: AppColors.bottomBar,
        currentTabPosition: 4,
        onDestinationSelected: _onTabSelected,
      ),
    );
  }
}
