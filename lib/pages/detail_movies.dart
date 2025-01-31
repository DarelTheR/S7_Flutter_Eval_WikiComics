import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:wikiwomics/res/app_colors.dart';
import 'package:wikiwomics/res/app_vectorial_images.dart';

class MovieDetailsPage extends StatefulWidget {
  final String movieId;

  const MovieDetailsPage({Key? key, required this.movieId}) : super(key: key);

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  Map<String, dynamic>? movieDetails;
  bool _isLoading = true;
  bool _hasError = false;
  final String _apiKey = "9423cc1c26178968a90ee233468fd390fd839876";
  final Map<String, String> _charactersImages = {};
  @override
  void initState() {
    super.initState();
    _fetchMovieDetails();
  }

  Future<void> _fetchMovieDetails() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse(
          "https://comicvine.gamespot.com/api/movie/4025-${widget.movieId}/?api_key=$_apiKey&format=json",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          movieDetails = data['results'];
        });

        await _fetchCharactersImages();

        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCharactersImages() async {
    if (movieDetails == null) return;
    final characters = movieDetails!['characters'] as List? ?? [];

    for (final character in characters) {
      final apiDetailUrl = character['api_detail_url'];
      if (apiDetailUrl == null) continue;

      final characterId = character['id']?.toString() ?? "";

      try {
        final url = "$apiDetailUrl?api_key=$_apiKey&format=json";
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final imageData = data['results']?['image'];
          if (imageData != null) {
            final bestUrl = imageData['medium_url'] ??
                imageData['original_url'] ??
                imageData['small_url'] ??
                'https://via.placeholder.com/50';

            _charactersImages[characterId] = bestUrl;
          }
        }
      } catch (_) {
        _charactersImages[characterId] = 'https://via.placeholder.com/50';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.section_1E3243,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? const Center(
                  child: Text(
                    "Erreur lors du chargement des détails.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            movieDetails?['image']?['medium_url'] ??
                'https://via.placeholder.com/150',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.6),
            colorBlendMode: BlendMode.darken,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.broken_image,
              size: 100,
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: Colors.white,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        movieDetails?['image']?['medium_url'] ??
                            'https://via.placeholder.com/150',
                        width: 120,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movieDetails?['name'] ?? "Titre inconnu",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            AppVectorialImages.icCalendarBicolor,
                            movieDetails?['release_date'] ?? "Date inconnue",
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            AppVectorialImages.icTvBicolor,
                            movieDetails?['runtime'] != null
                                ? "Durée : ${movieDetails?['runtime']} minutes"
                                : "Durée inconnue",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: const TabBar(
                            indicatorColor: Colors.orange,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.white,
                            indicatorWeight: 2,
                            tabs: [
                              Tab(text: "Synopsis"),
                              Tab(text: "Personnages"),
                              Tab(text: "Infos"),
                            ],
                          ),
                        ),
                      ),
                      Positioned.fill(
                        top: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.section_1E3243,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    SingleChildScrollView(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Html(
                                        data: movieDetails?['description'] ??
                                            "<p>Aucun synopsis disponible.</p>",
                                        style: {
                                          "body": Style(
                                            color: Colors.white,
                                            fontSize: FontSize(16.0),
                                            lineHeight: const LineHeight(1.5),
                                          ),
                                        },
                                      ),
                                    ),
                                    _buildCharactersTab(),
                                    _buildInfosTab(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCharactersTab() {
    final characters = movieDetails?['characters'] as List? ?? [];
    if (characters.isEmpty) {
      return const Center(
        child: Text(
          "Aucun personnage disponible.",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      itemCount: characters.length,
      itemBuilder: (context, index) {
        final character = characters[index];
        final characterName = character['name'] ?? "Nom inconnu";
        final characterId = character['id']?.toString() ?? "";
        final imageUrl =
            _charactersImages[characterId] ?? 'https://via.placeholder.com/50';

        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(40.0),
            child: Image.network(
              imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          title: Text(
            characterName,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildInfosTab() {
    final rating = movieDetails?['rating'] ?? "Note inconnue";
    final directors = movieDetails?['directors'] as List? ?? [];
    final writers = movieDetails?['writers'] as List? ?? [];
    final producers = movieDetails?['producers'] as List? ?? [];
    final studios = movieDetails?['studios'] as List? ?? [];

    final realisateursText = directors.isNotEmpty
        ? directors.map((d) => d['name']).join(', ')
        : "Inconnu";

    final scenaristesText = writers.isNotEmpty
        ? writers.map((d) => d['name']).join(', ')
        : "Inconnu";

    final producteursText = producers.isNotEmpty
        ? producers.map((p) => p['name']).join(', ')
        : "Inconnu";

    final studiosText = studios.isNotEmpty
        ? studios.map((s) => s['name']).join(', ')
        : "Inconnu";

    final budget = formatBudget(movieDetails?['budget']);
    final boxOffice = formatBudget(movieDetails?['box_office_revenue']);
    final recettesBrutesTotales = formatBudget(movieDetails?['total_gross']);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _infoItem("Classification", rating),
        _infoItem("Réalisateur(s)", realisateursText),
        _infoItem("Scénariste(s)", scenaristesText),
        _infoItem("Producteur(s)", producteursText),
        _infoItem("Studio(x)", studiosText),
        const SizedBox(height: 16),
        _infoItem("Budget", budget),
        _infoItem("Recettes au box-office", boxOffice),
        _infoItem("Recettes brutes totales", recettesBrutesTotales),
      ],
    );
  }

  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        "$label : $value",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
    );
  }

  String formatBudget(dynamic rawValue) {
    if (rawValue == null) {
      return "Non renseigné";
    }
    final value = (rawValue is int)
        ? rawValue.toDouble()
        : double.tryParse(rawValue.toString());
    if (value == null) {
      return "Non renseigné";
    }
    if (value >= 1000000) {
      final millions = value / 1000000;
      return "${millions.toStringAsFixed(0)} millions \$";
    } else {
      final formatted = value.toStringAsFixed(0);
      return "$formatted \$";
    }
  }

  Widget _buildInfoRow(String iconPath, String info) {
    return Row(
      children: [
        SvgPicture.asset(
          iconPath,
          width: 16,
          height: 16,
          color: Colors.white,
        ),
        const SizedBox(width: 8),
        Text(
          info,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
