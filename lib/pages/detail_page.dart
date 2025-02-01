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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DetailBloc()..add(LoadDetail(media)),
      child: Scaffold(
        backgroundColor: AppColors.Section_1E3243,
        body: BlocBuilder<DetailBloc, DetailState>(
          builder: (context, state) {
            if (state is DetailLoaded) {
              final mediaDetails = state.media;
              return Stack(
                children: [
                  // Image de fond avec overlay sombre
                  Positioned.fill(
                    child: Image.network(
                      mediaDetails['imageUrl'] ?? 'https://via.placeholder.com/150',
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
                  // Contenu principal par-dessus
                  Positioned.fill(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // AppBar transparent avec bouton retour
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
                              // Affichage de l'image du média
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  mediaDetails['imageUrl'] ?? 'https://via.placeholder.com/150',
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
                              // Informations principales : titre, date, info spécifique
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mediaDetails['title'] ?? "Titre inconnu",
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
                                      mediaDetails['releaseDate'] ?? "Date inconnue",
                                    ),
                                    const SizedBox(height: 8),
                                    _buildMediaSpecificInfoRow(mediaDetails),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Zone des onglets (Synopsis, Personnages, Infos)
                        Expanded(
                          child: DefaultTabController(
                            length: 3,
                            child: Column(
                              children: [
                                const TabBar(
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
                                      children: [
                                        // Onglet Synopsis
                                        SingleChildScrollView(
                                          child: Html(
                                            data: mediaDetails['description'] ??
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
                                        // Onglet Personnages
                                        _buildCharactersTab(mediaDetails),
                                        // Onglet Infos
                                        _buildInfosTab(mediaDetails),
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

  /// Affiche la deuxième ligne d’info en fonction du type de média
  Widget _buildMediaSpecificInfoRow(Map<String, dynamic> mediaDetails) {
    String infoText;
    if (mediaType == "Movie") {
      final runtime = mediaDetails['runtime'] != null ? "${mediaDetails['runtime']} minutes" : "Durée inconnue";
      infoText = "Durée : $runtime";
    } else if (mediaType == "Serie") {
      final episodes = mediaDetails['episodes'] != null ? "${mediaDetails['episodes']} épisodes" : "Inconnu";
      infoText = "$episodes";
    } else if (mediaType == "Comic") {
      final issueNumber = mediaDetails['issueNumber'] ?? "Inconnu";
      infoText = "Numéro d'édition : $issueNumber";
    } else {
      infoText = "";
    }
    return _buildInfoRow(AppVectorialImages.icTvBicolor, infoText);
  }

  /// Widget réutilisable pour une ligne d’info avec icône et texte
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

  /// Onglet Personnages : affiche la liste des personnages s’ils sont disponibles
  Widget _buildCharactersTab(Map<String, dynamic> mediaDetails) {
    final characters = mediaDetails['characters'] as List? ?? [];
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
        // On utilise ici une image de remplacement si aucune n'est fournie
        final imageUrl = character['imageUrl'] ?? 'https://via.placeholder.com/50';
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

  /// Onglet Infos : affiche quelques informations complémentaires sur le média
  Widget _buildInfosTab(Map<String, dynamic> mediaDetails) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _infoItem("Titre", mediaDetails['title'] ?? "Titre inconnu"),
        _infoItem("Studio", mediaDetails['studio'] ?? "Studio inconnu"),
        _infoItem("Date de sortie", mediaDetails['releaseDate'] ?? "Date inconnue"),
        if (mediaType == "Comic")
          _infoItem("Numéro d'édition", mediaDetails['issueNumber']?.toString() ?? "Inconnu"),
        if (mediaType == "Movie")
          _infoItem("Durée", "${mediaDetails['runtime'] ?? 'Durée inconnue'} minutes"),
        if (mediaType == "Serie")
          _infoItem("Épisodes", "${mediaDetails['episodes'] ?? 'Inconnu'} épisodes"),
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
}