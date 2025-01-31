import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wikiwomics/bloc/Detail_bloc/detail_bloc.dart';
import 'package:wikiwomics/res/app_colors.dart';

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> media;
  final String mediaType; // "Comic", "Movie", "Serie"

  const DetailPage({super.key, required this.media, required this.mediaType});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DetailBloc()..add(LoadDetail(media)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(media['title'] ?? "Titre inconnu"),
          backgroundColor: AppColors.Section_1E3243,
        ),
        body: BlocBuilder<DetailBloc, DetailState>(
          builder: (context, state) {
            if (state is DetailLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.network(
                          state.media['imageUrl'] ?? "https://via.placeholder.com/150",
                          width: 200,
                          height: 300,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.broken_image,
                            size: 120,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    _buildDetailRow("Titre", state.media['title'] ?? "Titre inconnu"),
                    _buildDetailRow("Studio", state.media['studio'] ?? "Studio inconnu"),
                    _buildDetailRow("Date de sortie", state.media['releaseDate'] ?? "Date inconnue"),

                    if (mediaType == "Comic")
                      _buildDetailRow("Numéro d'édition", state.media['issueNumber'] ?? "Inconnu"),

                    if (mediaType == "Movie")
                      _buildDetailRow("Durée", "${state.media['runtime'] ?? 'Durée inconnue'} minutes"),

                    if (mediaType == "Serie")
                      _buildDetailRow("Épisodes", "${state.media['episodes'] ?? 'Inconnu'} épisodes"),

                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Ajouté aux favoris!")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.Blue_3792FF,
                      ),
                      child: const Text("Ajouter aux favoris", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        "$label : $value",
        style: const TextStyle(fontSize: 18, color: Colors.white70),
      ),
    );
  }
}
