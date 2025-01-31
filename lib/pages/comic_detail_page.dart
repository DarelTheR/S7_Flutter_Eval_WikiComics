import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wikiwomics/bloc/ComicDetail_bloc/comic_detail_bloc.dart';
import 'package:wikiwomics/res/app_colors.dart';

class ComicDetailPage extends StatelessWidget {
  final Map<String, dynamic> comic;

  const ComicDetailPage({super.key, required this.comic});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ComicDetailBloc()..add(LoadComicDetail(comic)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(comic['title']),
          backgroundColor: AppColors.Section_1E3243,
        ),
        body: BlocBuilder<ComicDetailBloc, ComicDetailState>(
          builder: (context, state) {
            if (state is ComicDetailLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.network(
                          state.comic['imageUrl'],
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
                    Text(
                      "Titre: ${state.comic['title']}",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      "Studio: ${state.comic['studio']}",
                      style: const TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      "Date de sortie: ${state.comic['releaseDate']}",
                      style: const TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      "Numéro d'édition: ${state.comic['issueNumber']}",
                      style: const TextStyle(fontSize: 18, color: Colors.white70),
                    ),
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
}
