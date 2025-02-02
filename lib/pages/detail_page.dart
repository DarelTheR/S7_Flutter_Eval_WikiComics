import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:wikiwomics/bloc/Detail_bloc/detail_bloc.dart';
import 'package:wikiwomics/res/app_colors.dart';
import 'package:wikiwomics/res/app_vectorial_images.dart';

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> media;
  final String mediaType;

  const DetailPage({
    Key? key,
    required this.media,
    required this.mediaType,
  }) : super(key: key);

  String _getImageUrl(Map<String, dynamic> details) {
    if (details['image'] != null &&
        details['image'] is Map &&
        details['image']['medium_url'] != null) {
      return details['image']['medium_url'];
    }
    return "https://via.placeholder.com/150";
  }

  String _getTitle(Map<String, dynamic> details) {
    return details['name'] ?? "Titre inconnu";
  }

  String _getReleaseDate(Map<String, dynamic> details) {
    if (mediaType == "Serie") {
      return details['start_year'] ?? "Année inconnue";
    } else if (mediaType == "Comic") {
      return details['cover_date'] ?? "Date inconnue";
    }
    return details['release_date'] ?? "Date inconnue";
  }

  String _buildMediaSpecificInfo(Map<String, dynamic> details) {
    if (mediaType == "Movie") {
      final runtime = details['runtime'] != null
          ? "${details['runtime']} minutes"
          : "Durée inconnue";
      return "Durée : $runtime";
    } else if (mediaType == "Serie") {
      final episodesCount = details['count_of_episodes'] ??
          (details['episodes'] is List
              ? details['episodes'].length
              : "Inconnu");
      return "$episodesCount épisodes";
    } else if (mediaType == "Comic") {
      final issueNumber = details['issue_number'] ?? "Inconnu";
      return "Édition : #$issueNumber";
    }
    return "";
  }

  Future<String> _fetchImage(String apiDetailUrl) async {
    const fallbackUrl = "https://via.placeholder.com/50";
    const apiKey = "9423cc1c26178968a90ee233468fd390fd839876";
    try {
      final secureUrl = apiDetailUrl.replaceFirst("http://", "https://");
      final url = "$secureUrl?api_key=$apiKey&format=json";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'];
        if (results != null && results is Map) {
          final imageData = results['image'];
          if (imageData != null && imageData is Map) {
            return imageData['medium_url'] ??
                imageData['original_url'] ??
                imageData['small_url'] ??
                fallbackUrl;
          }
          if (results.containsKey('image_url') &&
              results['image_url'] != null) {
            return results['image_url'];
          }
        }
      }
    } catch (e) {}
    return fallbackUrl;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DetailBloc()..add(LoadDetail(media, mediaType)),
      child: Scaffold(
        backgroundColor: AppColors.Background,
        body: BlocBuilder<DetailBloc, DetailState>(
          builder: (context, state) {
            if (state is DetailLoaded) {
              final details = state.media;
              if (mediaType == "Character") {
                return _buildCharacterContent(context, details);
              } else {
                return _buildDefaultContent(context, details);
              }
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildDefaultContent(
      BuildContext context, Map<String, dynamic> details) {
    final mainImageUrl = _getImageUrl(details);
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            mainImageUrl,
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.6),
            colorBlendMode: BlendMode.darken,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 100, color: Colors.white),
          ),
        ),
        Positioned.fill(
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
                        mainImageUrl,
                        width: 120,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image,
                                size: 120, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mediaType == "Comic"
                                ? (details['volume'] != null &&
                                        details['volume']['name'] != null
                                    ? details['volume']['name']
                                    : "Titre inconnu")
                                : _getTitle(details),
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (mediaType == "Comic")
                            Text(
                              details['issue_title'] != null &&
                                      details['issue_title']
                                          .toString()
                                          .isNotEmpty
                                  ? details['issue_title']
                                  : "Titre d'issue non renseigné",
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white70),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 8),
                          _buildInfoRow(AppVectorialImages.icCalendarBicolor,
                              _getReleaseDate(details)),
                          const SizedBox(height: 8),
                          _buildInfoRow(AppVectorialImages.icTvBicolor,
                              _buildMediaSpecificInfo(details)),
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
                                Tab(text: "Personnages")
                              ]
                            : mediaType == "Serie"
                                ? const [
                                    Tab(text: "Histoire"),
                                    Tab(text: "Personnages"),
                                    Tab(text: "Episodes")
                                  ]
                                : const [
                                    Tab(text: "Synopsis"),
                                    Tab(text: "Personnages"),
                                    Tab(text: "Infos")
                                  ],
                      ),
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.Background,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16)),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: TabBarView(
                            children: mediaType == "Comic"
                                ? [
                                    SingleChildScrollView(
                                        child: Html(
                                            data: cleanHtml(details[
                                                    'description'] ??
                                                "<p>Aucune histoire disponible.</p>"),
                                            style: {
                                          "body": Style(
                                              color: Colors.white,
                                              fontSize: FontSize(16.0),
                                              lineHeight: LineHeight(1.5)),
                                          "img": Style(display: Display.none)
                                        })),
                                    _buildComicAuthorsTab(details),
                                    _buildComicCharactersTab(details),
                                  ]
                                : mediaType == "Serie"
                                    ? [
                                        SingleChildScrollView(
                                            child: Html(
                                                data: cleanHtml(details[
                                                        'description'] ??
                                                    "<p>Aucune histoire disponible.</p>"),
                                                style: {
                                              "body": Style(
                                                  color: Colors.white,
                                                  fontSize: FontSize(16.0),
                                                  lineHeight: LineHeight(1.5)),
                                              "img":
                                                  Style(display: Display.none)
                                            })),
                                        _buildCharactersTab(details),
                                        _buildEpisodesTab(details),
                                      ]
                                    : [
                                        SingleChildScrollView(
                                            child: Html(
                                                data: cleanHtml(details[
                                                        'description'] ??
                                                    "<p>Aucun synopsis disponible.</p>"),
                                                style: {
                                              "body": Style(
                                                  color: Colors.white,
                                                  fontSize: FontSize(16.0),
                                                  lineHeight: LineHeight(1.5)),
                                              "img":
                                                  Style(display: Display.none)
                                            })),
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

  Widget _buildCharacterContent(
      BuildContext context, Map<String, dynamic> details) {
    final mainImageUrl = _getImageUrl(details);
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            mainImageUrl,
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.6),
            colorBlendMode: BlendMode.darken,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 100, color: Colors.white),
          ),
        ),
        Positioned.fill(
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
                        mainImageUrl,
                        width: 120,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image,
                                size: 120, color: Colors.white),
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
                                color: Colors.white),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Alias: " + (details['aliases'] ?? "Aucun alias"),
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white70),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(AppVectorialImages.icCalendarBicolor,
                              "Naissance: " + (details['birth'] ?? "Inconnu")),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        indicatorColor: Colors.orange,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white,
                        indicatorWeight: 2,
                        tabs: [Tab(text: "Histoire"), Tab(text: "Infos")],
                      ),
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.Section_1E3243,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16)),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: TabBarView(
                            children: [
                              SingleChildScrollView(
                                child: Html(
                                    data: cleanHtml(details['description'] ??
                                        "<p>Aucune description disponible.</p>"),
                                    style: {
                                      "body": Style(
                                          color: Colors.white,
                                          fontSize: FontSize(16.0),
                                          lineHeight: LineHeight(1.5))
                                    }),
                              ),
                              _buildCharacterInfosTab(details),
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
        Text(info, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildCharactersTab(Map<String, dynamic> details) {
    final characters = details['characters'] as List? ?? [];
    if (characters.isEmpty) {
      return Center(
          child: Text("Aucun personnage disponible.",
              style: TextStyle(color: Colors.white)));
    }
    return ListView.builder(
      itemCount: characters.length,
      itemBuilder: (context, index) {
        final character = characters[index];
        final characterName = character['name'] ?? "Nom inconnu";
        if (character['image'] != null &&
            character['image'] is Map &&
            character['image']['medium_url'] != null) {
          final imageUrl = character['image']['medium_url'];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(40.0),
              child: Image.network(
                imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            title: Text(characterName, style: TextStyle(color: Colors.white)),
          );
        } else if (character['api_detail_url'] != null) {
          return FutureBuilder<String>(
            future: _fetchImage(character['api_detail_url']),
            builder: (context, snapshot) {
              final url = snapshot.data ?? "https://via.placeholder.com/50";
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(40.0),
                  child: Image.network(
                    url,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
                title:
                    Text(characterName, style: TextStyle(color: Colors.white)),
              );
            },
          );
        } else {
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(40.0),
              child: Image.network(
                "https://via.placeholder.com/50",
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            title: Text(characterName, style: TextStyle(color: Colors.white)),
          );
        }
      },
    );
  }

  Widget _buildInfosTab(Map<String, dynamic> details) {
    if (mediaType == "Movie") {
      String classification = details['rating'] ?? "Non renseigné";
      String director = details['director'] ?? "Non renseigné";
      String scenaristes = "Non renseigné";
      if (details['writers'] != null &&
          details['writers'] is List &&
          (details['writers'] as List).isNotEmpty) {
        scenaristes = (details['writers'] as List)
            .map((writer) => writer['name'])
            .join(', ');
      }
      String producteurs = "Non renseigné";
      if (details['producers'] != null &&
          details['producers'] is List &&
          (details['producers'] as List).isNotEmpty) {
        producteurs = (details['producers'] as List)
            .map((producer) => producer['name'])
            .join(', ');
      }
      String studios = "Non renseigné";
      if (details['studios'] != null &&
          details['studios'] is List &&
          (details['studios'] as List).isNotEmpty) {
        studios = (details['studios'] as List)
            .map((studio) => studio['name'])
            .join(', ');
      }
      String budget = details['budget'] != null
          ? "${formatNumberWithSpaces(details['budget'])} \$"
          : "Non renseigné";
      String recettesBoxOffice = details['box_office_revenue'] != null
          ? "${formatNumberWithSpaces(details['box_office_revenue'])} \$"
          : "Non renseigné";
      String recettesTotales = details['total_revenue'] != null
          ? "${formatNumberWithSpaces(details['total_revenue'])} \$"
          : "Non renseigné";
      return ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _infoItem("Classification", classification),
          _infoItem("Réalisateur", director),
          _infoItem("Scénaristes", scenaristes),
          _infoItem("Producteurs", producteurs),
          _infoItem("Studios", studios),
          _infoItem("Budget", budget),
          _infoItem("Recettes au box-office", recettesBoxOffice),
          _infoItem("Recettes brutes totales", recettesTotales),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _buildEpisodesTab(Map<String, dynamic> details) {
    final episodes = details['episodes'] as List? ?? [];
    if (episodes.isEmpty) {
      return Center(
          child: Text("Aucun épisode disponible.",
              style: TextStyle(color: Colors.white)));
    }

    return ListView.builder(
      itemCount: episodes.length,
      itemBuilder: (context, index) {
        final episode = episodes[index];
        final episodeName = episode['name'] ?? "Épisode inconnu";
        final episodeNumberDisplay = "Épisode ${index + 1}";
        final episodeImageUrl = (episode['image'] != null &&
                episode['image'] is Map &&
                episode['image']['medium_url'] != null)
            ? episode['image']['medium_url']
            : 'https://via.placeholder.com/50';

        return Card(
          color: AppColors.Section_1E3243,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Container(
            height: 120,
            padding: const EdgeInsets.all(12.0),
            child: ListTile(
              leading: SizedBox(
                width: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    episodeImageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(),
                  ),
                ),
              ),
              title: Text(
                "$episodeNumberDisplay - $episodeName",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text("$label : $value",
          style: const TextStyle(color: Colors.white, fontSize: 16.0)),
    );
  }

  String formatNumberWithSpaces(String number) {
    return number.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'), (Match m) => '${m[1]} ');
  }

  Widget _buildComicAuthorsTab(Map<String, dynamic> details) {
    final authors = details['person_credits'] as List? ?? [];
    if (authors.isEmpty) {
      return Center(
          child: Text("Aucun auteur disponible.",
              style: TextStyle(color: Colors.white70)));
    }
    return ListView.builder(
      itemCount: authors.length,
      itemBuilder: (context, index) {
        final author = authors[index];
        final authorName = author['name'] ?? "Nom inconnu";
        if (author['image'] != null &&
            author['image'] is Map &&
            author['image']['medium_url'] != null) {
          final imageUrl = author['image']['medium_url'];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(40.0),
              child: Image.network(
                imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            title: Text(authorName, style: TextStyle(color: Colors.white)),
            subtitle: Text(author['role'] ?? "",
                style: TextStyle(color: Colors.white70)),
          );
        } else if (author['api_detail_url'] != null) {
          return FutureBuilder<String>(
            future: _fetchImage(author['api_detail_url']),
            builder: (context, snapshot) {
              final url = snapshot.data ?? "https://via.placeholder.com/50";
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(40.0),
                  child: Image.network(
                    url,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
                title: Text(authorName, style: TextStyle(color: Colors.white)),
                subtitle: Text(author['role'] ?? "",
                    style: TextStyle(color: Colors.white70)),
              );
            },
          );
        } else {
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(40.0),
              child: Image.network(
                "https://via.placeholder.com/50",
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            title: Text(authorName, style: TextStyle(color: Colors.white)),
            subtitle: Text(author['role'] ?? "",
                style: TextStyle(color: Colors.white70)),
          );
        }
      },
    );
  }

  Widget _buildComicCharactersTab(Map<String, dynamic> details) {
    final characters = details['character_credits'] as List? ?? [];
    if (characters.isEmpty) {
      return Center(
          child: Text("Aucun personnage disponible.",
              style: TextStyle(color: Colors.white)));
    }
    return ListView.builder(
      itemCount: characters.length,
      itemBuilder: (context, index) {
        final character = characters[index];
        final characterName = character['name'] ?? "Nom inconnu";
        if (character['image'] != null &&
            character['image'] is Map &&
            character['image']['medium_url'] != null) {
          final imageUrl = character['image']['medium_url'];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(40.0),
              child: Image.network(
                imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            title: Text(characterName, style: TextStyle(color: Colors.white)),
          );
        } else if (character['api_detail_url'] != null) {
          return FutureBuilder<String>(
            future: _fetchImage(character['api_detail_url']),
            builder: (context, snapshot) {
              final url = snapshot.data ?? "https://via.placeholder.com/50";
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(40.0),
                  child: Image.network(
                    url,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
                title:
                    Text(characterName, style: TextStyle(color: Colors.white)),
              );
            },
          );
        } else {
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(40.0),
              child: Image.network(
                "https://via.placeholder.com/50",
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            title: Text(characterName, style: TextStyle(color: Colors.white)),
          );
        }
      },
    );
  }

  Widget _buildCharacterInfosTab(Map<String, dynamic> details) {
    String superheroName = details['name'] ?? "Inconnu";
    String realName = details['real_name'] ?? "Inconnu";
    String aliases = details['aliases'] ?? "Aucun alias";
    String publisher = details['publisher']?["name"] ?? "Inconnu";
    String gender = details['gender'] == 1
        ? "Homme"
        : details['gender'] == 2
            ? "Femme"
            : "Inconnu";
    String birth = details['birth'] ?? "Inconnu";
    String death = details['death'] ?? "Inconnu";
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _infoItem("Nom de super héros", superheroName),
        _infoItem("Nom réel", realName),
        _infoItem("Alias", aliases),
        _infoItem("Éditeur", publisher),
        _infoItem("Genre", gender),
        _infoItem("Date de naissance", birth),
        _infoItem("Décès", death),
      ],
    );
  }

  Widget _buildCharacterEnemiesTab(Map<String, dynamic> details) {
    final enemies = details['character_enemies'] as List? ?? [];
    if (enemies.isEmpty) {
      return Center(
          child: Text("Aucun ennemi disponible.",
              style: TextStyle(color: Colors.white)));
    }
    return ListView.builder(
      itemCount: enemies.length,
      itemBuilder: (context, index) {
        final enemy = enemies[index];
        final enemyName = enemy['name'] ?? "Nom inconnu";
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(40.0),
            child: Image.network(
              'https://via.placeholder.com/50',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          title: Text(enemyName, style: TextStyle(color: Colors.white)),
        );
      },
    );
  }

  String cleanHtml(String html) {
    return html.replaceAllMapped(RegExp(r'<img[^>]+src="([^">]+)"[^>]*>'),
        (match) => '<img src="${match.group(1)}" />');
  }
}
