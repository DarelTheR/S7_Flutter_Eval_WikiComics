import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wikiwomics/bloc/Search_bloc/search_bloc.dart';
import 'package:wikiwomics/pages/detail_page.dart';
import 'package:wikiwomics/components/customNavigationBar.dart';
import 'package:wikiwomics/components/media_card.dart';
import 'package:wikiwomics/res/app_colors.dart';
import 'package:wikiwomics/res/app_vectorial_images.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(),
      child: Scaffold(
        backgroundColor: AppColors.Section_1E3243,
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
                      child: BlocBuilder<SearchBloc, SearchState>(
                        builder: (context, state) {
                          return TextField(
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
                            onSubmitted: (value) {
                              context.read<SearchBloc>().add(PerformSearch(value));
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state is SearchLoading) {
                      return Center(
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
                      );
                    } else if (state is SearchLoaded) {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildSection("Séries", state.seriesResults),
                            _buildSection("Comics", state.comicsResults),
                            _buildSection("Films", state.moviesResults),
                            _buildSection("Personnages", state.charactersResults),
                          ],
                        ),
                      );
                    } else if (state is SearchError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    } else {
                      return _buildInitialMessage();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const CustomNavigationBar(
          backgroundColor: AppColors.Bottom_bar,
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> results) {
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
          results.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Aucun résultat trouvé",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      String mediaType = "";
                      switch (title) {
                        case "Séries":
                          mediaType = "Serie";
                          break;
                        case "Comics":
                          mediaType = "Comic";
                          break;
                        case "Films":
                          mediaType = "Movie";
                          break;
                        case "Personnages":
                          mediaType = "Character";
                          break;
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailPage(
                                media: results[index],
                                mediaType: mediaType,
                              ),
                            ),
                          );
                        },
                        child: MediaCard(
                          imageUrl: results[index]["imageUrl"]!,
                          title: results[index]["title"]!,
                        ),
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
}
