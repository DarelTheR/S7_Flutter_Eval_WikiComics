import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wikiwomics/bloc/Detail_bloc/detail_bloc.dart';
import 'package:wikiwomics/res/app_colors.dart';
import 'package:wikiwomics/res/app_vectorial_images.dart';

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> media;
  final String mediaType; // "Comic", "Movie", "Serie"

  const DetailPage({
    Key? key,
    required this.media,
    required this.mediaType,
  }) : super(key: key);

  /// Retourne l'URL de l'image principale depuis la map "image".
  String _getImageUrl(Map<String, dynamic> details) {
    if (details['image'] != null &&
        details['image'] is Map &&
        details['image']['medium_url'] != null) {
      return details['image']['medium_url'];
    }
    return "https://via.placeholder.com/150";
  }

  /// Retourne le titre.
  /// Pour un comic, si "name" est vide ou null, on utilise le nom du volume et le numéro d'issue.
  String _getTitle(Map<String, dynamic> details) {
    if (mediaType == "Comic") {
      if (details['name'] == null || details['name'].toString().isEmpty) {
        String volumeName = details['volume'] != null && details['volume']['name'] != null
            ? details['volume']['name']
            : "Comic";
        String issueNumber = details['issue_number'] ?? "Inconnu";
        return "$volumeName #$issueNumber";
      }
    }
    return details['name'] ?? "Titre inconnu";
  }

  /// Retourne la date.
  /// Pour les séries, utilise "start_year"; pour les comics, "cover_date"; sinon "release_date".
  String _getReleaseDate(Map<String, dynamic> details) {
    if (mediaType == "Serie") {
      return details['start_year'] ?? "Année inconnue";
    } else if (mediaType == "Comic") {
      return details['cover_date'] ?? "Date inconnue";
    }
    return details['release_date'] ?? "Date inconnue";
  }

  /// Retourne une info spécifique.
  /// - Movie : durée (runtime)
  /// - Serie : nombre d'épisodes (via "count_of_episodes" ou longueur de "episodes")
  /// - Comic : affiche "Édition : #issue_number"
  String _buildMediaSpecificInfo(Map<String, dynamic> details) {
    if (mediaType == "Movie") {
      final runtime = details['runtime'] != null ? "${details['runtime']} minutes" : "Durée inconnue";
      return "Durée : $runtime";
    } else if (mediaType == "Serie") {
      final episodesCount = details['count_of_episodes'] ??
          (details['episodes'] is List ? details['episodes'].length : "Inconnu");
      return "$episodesCount épisodes";
    } else if (mediaType == "Comic") {
      final issueNumber = details['issue_number'] ?? "Inconnu";
      return "Édition : #$issueNumber";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DetailBloc()..add(LoadDetail(media, mediaType)),
      child: Scaffold(
        backgroundColor: AppColors.Section_1E3243,
        body: BlocBuilder<DetailBloc, DetailState>(
          builder: (context, state) {
            if (state is DetailLoaded) {
              final details = state.media;
              final mainImageUrl = _getImageUrl(details);
              return Stack(
                children: [
                  // Fond : image avec overlay sombre.
                  Positioned.fill(
                    child: Image.network(
                      mainImageUrl,
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
                  // Contenu principal.
                  Positioned.fill(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // AppBar transparente avec bouton retour.
                        AppBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          leading: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            color: Colors.white,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        // En-tête : affiche l'image et les informations principales.
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  mainImageUrl,
                                  width: 120,
                                  height: 180,
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
                                  children: [
                                    Text(
                                      _getTitle(details),
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
                                      _getReleaseDate(details),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      AppVectorialImages.icTvBicolor,
                                      _buildMediaSpecificInfo(details),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Onglets.
                        Expanded(
                          child: DefaultTabController(
                            length: 3,
                            child: Column(
                              children: [
                                TabBar(
                                  indicatorColor: Colors.orange,
                                  labelColor: Colors.white,
                                  unselectedLabelColor: Colors.white,
                                  indicatorWeight: 2,
                                  tabs: mediaType == "Comic"
                                      ? const [
                                          Tab(text: "Histoire"),
                                          Tab(text: "Auteurs"),
                                          Tab(text: "Personnages"),
                                        ]
                                      : mediaType == "Serie"
                                          ? const [
                                              Tab(text: "Histoire"),
                                              Tab(text: "Personnages"),
                                              Tab(text: "Episodes"),
                                            ]
                                          : const [
                                              Tab(text: "Synopsis"),
                                              Tab(text: "Personnages"),
                                              Tab(text: "Infos"),
                                            ],
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: AppColors.Section_1E3243,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    child: TabBarView(
                                      children: mediaType == "Comic"
                                          ? [
                                              // Onglet "Histoire" pour comics.
                                              SingleChildScrollView(
                                                child: Html(
                                                  data: details['description'] ??
                                                      "<p>Aucune histoire disponible.</p>",
                                                  style: {
                                                    "body": Style(
                                                      color: Colors.white,
                                                      fontSize: FontSize(16.0),
                                                      lineHeight: LineHeight(1.5),
                                                    ),
                                                  },
                                                ),
                                              ),
                                              // Onglet "Auteurs" pour comics.
                                              _buildComicAuthorsTab(details),
                                              // Onglet "Personnages" pour comics.
                                              _buildComicCharactersTab(details),
                                            ]
                                          : mediaType == "Serie"
                                              ? [
                                                  // Pour les séries.
                                                  SingleChildScrollView(
                                                    child: Html(
                                                      data: details['description'] ??
                                                          "<p>Aucune histoire disponible.</p>",
                                                      style: {
                                                        "body": Style(
                                                          color: Colors.white,
                                                          fontSize: FontSize(16.0),
                                                          lineHeight: LineHeight(1.5),
                                                        ),
                                                      },
                                                    ),
                                                  ),
                                                  _buildCharactersTab(details),
                                                  _buildEpisodesTab(details),
                                                ]
                                              : [
                                                  // Pour les films et autres.
                                                  SingleChildScrollView(
                                                    child: Html(
                                                      data: details['description'] ??
                                                          "<p>Aucun synopsis disponible.</p>",
                                                      style: {
                                                        "body": Style(
                                                          color: Colors.white,
                                                          fontSize: FontSize(16.0),
                                                          lineHeight: LineHeight(1.5),
                                                        ),
                                                      },
                                                    ),
                                                  ),
                                                  _buildCharactersTab(details),
                                                  _buildInfosTab(details),
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
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
  
  /// Widget utilitaire pour afficher une ligne d'information avec une icône.
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
  
  /// Affiche la liste des personnages pour films et séries.
  Widget _buildCharactersTab(Map<String, dynamic> details) {
    final characters = details['characters'] as List? ?? [];
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
        final imageUrl = character['image']?['medium_url'] ?? 'https://via.placeholder.com/50';
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(40.0),
            child: Image.network(
              imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
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
  
  /// Pour les films, affiche des infos complémentaires (budget, recettes, etc.).
  Widget _buildInfosTab(Map<String, dynamic> details) {
    if (mediaType == "Movie") {
      return ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _infoItem("Budget", details['budget'] != null ? "${details['budget']} \$" : "Non renseigné"),
          _infoItem("Recettes Box-Office", details['box_office_revenue'] != null ? "${details['box_office_revenue']} \$" : "Non renseigné"),
        ],
      );
    } else {
      return Container();
    }
  }
  
  /// Pour les séries, affiche la liste des épisodes.
  Widget _buildEpisodesTab(Map<String, dynamic> details) {
    final episodes = details['episodes'] as List? ?? [];
    if (episodes.isEmpty) {
      return const Center(
        child: Text(
          "Aucun épisode disponible.",
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    return ListView.builder(
      itemCount: episodes.length,
      itemBuilder: (context, index) {
        final episode = episodes[index];
        final episodeName = episode['name'] ?? "Épisode inconnu";
        final episodeNumberDisplay = "Épisode ${index + 1}";
        return ListTile(
          title: Text(
            "$episodeNumberDisplay - $episodeName",
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
  
  /// Affiche un item d'information.
  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        "$label : $value",
        style: const TextStyle(color: Colors.white, fontSize: 16.0),
      ),
    );
  }
  
  /// Widgets spécifiques pour les comics.
  
  /// Affiche la liste des auteurs pour les comics à partir de la clé "person_credits".
  Widget _buildComicAuthorsTab(Map<String, dynamic> details) {
    final authors = details['person_credits'] as List? ?? [];
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
        final authorName = author['name'] ?? "Nom inconnu";
        final imageUrl = (author['image'] != null &&
                author['image'] is Map &&
                author['image']['medium_url'] != null)
            ? author['image']['medium_url']
            : 'https://via.placeholder.com/50';
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(40.0),
            child: Image.network(
              imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          title: Text(authorName, style: const TextStyle(color: Colors.white)),
          subtitle: Text(author['role'] ?? "", style: const TextStyle(color: Colors.white70)),
        );
      },
    );
  }
  
  /// Affiche la liste des personnages pour les comics à partir de la clé "character_credits".
  Widget _buildComicCharactersTab(Map<String, dynamic> details) {
    final characters = details['character_credits'] as List? ?? [];
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
        final imageUrl = character['image']?['medium_url'] ?? 'https://via.placeholder.com/50';
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(40.0),
            child: Image.network(
              imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          title: Text(characterName, style: const TextStyle(color: Colors.white)),
        );
      },
    );
  }
}
