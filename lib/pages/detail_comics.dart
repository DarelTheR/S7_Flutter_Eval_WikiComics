import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:wikiwomics/res/app_colors.dart';
import 'package:wikiwomics/res/app_vectorial_images.dart';

class ComicDetailsPage extends StatefulWidget {
  final String comicId;
  const ComicDetailsPage({super.key, required this.comicId});

  @override
  State<ComicDetailsPage> createState() => _ComicDetailsPageState();
}

class _ComicDetailsPageState extends State<ComicDetailsPage> {
  Map<String, dynamic>? comicDetails;
  bool _isLoading = true;
  bool _hasError = false;

  final String _apiKey = "91af37aec2e88b4f28ab323c9130d96787c22b2e";

  final Map<String, String> _authorsImages = {};
  final Map<String, String> _charactersImages = {};

  @override
  void initState() {
    super.initState();
    _fetchComicDetails();
  }

  Future<void> _fetchComicDetails() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse(
          "https://comicvine.gamespot.com/api/issue/4000-${widget.comicId}/?api_key=$_apiKey&format=json",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          comicDetails = data['results'];
        });

        await _fetchAuthorsImages();
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

  Future<void> _fetchAuthorsImages() async {
    if (comicDetails == null) return;
    final authors = comicDetails!['person_credits'] as List? ?? [];

    for (final author in authors) {
      final apiDetailUrl = author['api_detail_url'];
      if (apiDetailUrl == null) continue;

      final personId = author['id']?.toString() ?? "";

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

            _authorsImages[personId] = bestUrl;
          }
        }
      } catch (_) {
        _authorsImages[personId] = 'https://via.placeholder.com/50';
      }
    }
  }

  Future<void> _fetchCharactersImages() async {
    if (comicDetails == null) return;
    final characters = comicDetails!['character_credits'] as List? ?? [];

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
            comicDetails?['image']?['medium_url'] ??
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
                        comicDetails?['image']?['medium_url'] ??
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
                            comicDetails?['name'] ?? "Titre inconnu",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formatDescription(comicDetails?['description']),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            AppVectorialImages.icBooksBicolor,
                            "N° ${comicDetails?['issue_number'] ?? 'Inconnu'}",
                          ),
                          _buildInfoRow(
                            AppVectorialImages.icCalendarBicolor,
                            comicDetails?['cover_date'] ?? "Date inconnue",
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
                            indicatorPadding: EdgeInsets.zero,
                            tabs: [
                              Tab(text: "Histoire"),
                              Tab(text: "Auteurs"),
                              Tab(text: "Personnages"),
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
                                        horizontal: 16.0,
                                      ),
                                      child: Html(
                                        data: comicDetails?['description'] ??
                                            "<p>Aucune description disponible.</p>",
                                        style: {
                                          "body": Style(
                                            color: Colors.white,
                                            fontSize: FontSize(16.0),
                                            lineHeight: const LineHeight(1.5),
                                          ),
                                        },
                                      ),
                                    ),
                                    _buildAuthorsTab(),
                                    _buildCharactersTab(),
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

  Widget _buildAuthorsTab() {
    final authors = comicDetails?['person_credits'] as List? ?? [];
    if (authors.isEmpty) {
      return const Center(
        child: Text(
          "Aucun auteur disponible.",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      itemCount: authors.length,
      itemBuilder: (context, index) {
        final author = authors[index];
        final personId = author['id']?.toString() ?? "";
        final finalUrl = _authorsImages[personId];

        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(40.0),
            child: Image.network(
              finalUrl ?? 'https://via.placeholder.com/50',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          title: Text(
            author['name'] ?? "Nom inconnu",
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            author['role'] ?? "",
            style: const TextStyle(color: Colors.white70),
          ),
        );
      },
    );
  }

  Widget _buildCharactersTab() {
    final characters = comicDetails?['character_credits'] as List? ?? [];
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
        final characterId = character['id']?.toString() ?? "";
        final finalUrl = _charactersImages[characterId];

        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(40.0),
            child: Image.network(
              finalUrl ?? 'https://via.placeholder.com/50',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          title: Text(
            character['name'] ?? "Nom inconnu",
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
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

String formatDescription(String? description) {
  if (description == null || description.isEmpty) {
    return "Aucune description disponible.";
  }
  final plainText = description.replaceAll(RegExp(r"<[^>]*>"), "");
  final words = plainText.split(" ");
  if (words.length <= 5) {
    return plainText;
  }
  final firstWords = words.take(4).join(" ");
  final lastWord = words.last;
  return "$firstWords ... $lastWord";
}
