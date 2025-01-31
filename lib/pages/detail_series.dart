import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:wikiwomics/res/app_colors.dart';
import 'package:wikiwomics/res/app_vectorial_images.dart';

class SeriesDetailsPage extends StatefulWidget {
  final String seriesId;

  const SeriesDetailsPage({
    Key? key,
    required this.seriesId,
  }) : super(key: key);

  @override
  State<SeriesDetailsPage> createState() => _SeriesDetailsPageState();
}

class _SeriesDetailsPageState extends State<SeriesDetailsPage> {
  Map<String, dynamic>? seriesDetails;
  bool _isLoading = true;
  bool _hasError = false;

  final String _apiKey = "91af37aec2e88b4f28ab323c9130d96787c22b2e";

  @override
  void initState() {
    super.initState();
    _fetchSeriesDetails();
  }

  Future<void> _fetchSeriesDetails() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final url = "https://api.formation-android.fr/comicvine?url=series_detail"
        "&id=${widget.seriesId}"
        "&api_key=$_apiKey&format=json";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          seriesDetails = data['results'];
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
            seriesDetails?['image']?['medium_url'] ??
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
                        seriesDetails?['image']?['medium_url'] ??
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
                            seriesDetails?['name'] ?? "Titre inconnu",
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
                            seriesDetails?['start_year'] != null
                                ? "Début : ${seriesDetails?['start_year']}"
                                : "Début inconnu",
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
                                        horizontal: 16.0,
                                      ),
                                      child: Html(
                                        data: seriesDetails?['description'] ??
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
    final characters = seriesDetails?['characters'] as List? ?? [];
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
        final imageUrl = character['image']?['medium_url'] ??
            'https://via.placeholder.com/50';

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
    final rating = seriesDetails?['rating'] ?? "Note inconnue";

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _infoItem("Classification", rating),
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
