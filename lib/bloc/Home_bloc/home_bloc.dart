import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final String _apiKey = "91af37aec2e88b4f28ab323c9130d96787c22b2e";

  HomeBloc() : super(HomeInitial()) {
    on<FetchHomeData>(_onFetchHomeData);
  }

  Future<void> _onFetchHomeData(FetchHomeData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final series = await _fetchItems("series_list");
      final comics = await _fetchItems("issues");
      final movies = await _fetchItems("movies");
      final characters = await _fetchItems("characters");

      emit(HomeLoaded(series, comics, movies, characters));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<List<Map<String, dynamic>>> _fetchItems(String endpoint) async {
    final apiUrl =
        "https://api.formation-android.fr/comicvine?url=$endpoint&api_key=$_apiKey&format=json";
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['results'] as List).map((item) {
        return {
          "id": item["id"],
          "imageUrl": item["image"]?["medium_url"] ?? "",
          "title": item["name"] ?? "Titre inconnu",
        };
      }).toList();
    }
    throw Exception("Erreur de chargement des données pour $endpoint");
  }
}
