import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:wikiwomics/components/customNavigationBar.dart';
import 'package:wikiwomics/components/media_card.dart';
import 'package:wikiwomics/res/app_colors.dart';
import 'package:wikiwomics/res/app_vectorial_images.dart';

import '../app_routes.dart';

abstract class HomeEvent {}

class FetchSectionEvent extends HomeEvent {
  final String endpoint;

  FetchSectionEvent(this.endpoint);
}

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final Map<String, List<Map<String, dynamic>>> sections;

  HomeLoaded(this.sections);
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final String _apiKey = "91af37aec2e88b4f28ab323c9130d96787c22b2e";

  HomeBloc() : super(HomeInitial()) {
    on<FetchSectionEvent>(_fetchSection);
  }

  Future<void> _fetchSection(
      FetchSectionEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final sections = await _fetchSections();
      emit(HomeLoaded(sections));
    } catch (e) {
      emit(HomeError("Erreur lors du chargement des données"));
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> _fetchSections() async {
    final endpoints = {
      "Séries populaires": "series_list",
      "Comics populaires": "issues",
      "Films populaires": "movies",
      "Personnages": "characters",
    };

    Map<String, List<Map<String, dynamic>>> results = {};

    for (var entry in endpoints.entries) {
      final response = await http.get(Uri.parse(
          "https://api.formation-android.fr/comicvine?url=${entry.value}&api_key=$_apiKey&format=json"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        results[entry.key] = (data['results'] as List).map((item) {
          return {
            "imageUrl": item["image"]?["medium_url"] ?? "",
            "title": item["name"] ?? "Titre inconnu",
          };
        }).toList();
      } else {
        results[entry.key] = [];
      }
    }
    return results;
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc()..add(FetchSectionEvent("init")),
      child: Scaffold(
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeInitial) {
              return const Center(child: Text("Chargement des données..."));
            } else if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HomeLoaded) {
              return _buildContent(context, state.sections);
            } else if (state is HomeError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
        bottomNavigationBar: CustomNavigationBar(
          backgroundColor: AppColors.bottomBar,
          currentTabPosition: 0,
          onDestinationSelected: (index) {
            _onTabSelected(context, index);
          },
        ),
      ),
    );
  }

  void _onTabSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
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

  Widget _buildContent(
      BuildContext context, Map<String, List<Map<String, dynamic>>> sections) {
    final Map<String, int> sectionIndices = {
      "Séries populaires": 2,
      "Comics populaires": 1,
      "Films populaires": 3,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Row(
            children: [
              const Text(
                'Bienvenue !',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              SvgPicture.asset(
                AppVectorialImages.astronaut,
                width: 84,
                height: 84,
              ),
            ],
          ),
          const SizedBox(height: 32),
          for (var entry in sections.entries)
            _buildSectionWithMore(entry.key, entry.value, () {
              if (sectionIndices.containsKey(entry.key)) {
                final index = sectionIndices[entry.key]!;
                _onTabSelected(context, index);
              }
            }),
        ],
      ),
    );
  }

  Widget _buildSectionWithMore(String title, List<Map<String, dynamic>> results,
      VoidCallback onMorePressed) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              if (title != "Personnages")
                TextButton(
                  onPressed: onMorePressed,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    backgroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    "Voir plus",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _buildHorizontalList(results),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(List<Map<String, dynamic>> items) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return MediaCard(
            imageUrl: items[index]["imageUrl"]!,
            title: items[index]["title"]!,
          );
        },
      ),
    );
  }
}
