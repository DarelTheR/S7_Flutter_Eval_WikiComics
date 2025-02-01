// lib/bloc/search_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final String _apiKey = "9423cc1c26178968a90ee233468fd390fd839876";

  SearchBloc() : super(SearchInitial()) {
    on<PerformSearch>(_onPerformSearch);
  }

  Future<void> _onPerformSearch(PerformSearch event, Emitter<SearchState> emit) async {
    if (event.query.isEmpty) {
      emit(SearchError("Veuillez entrer un terme à rechercher"));
      return;
    }

    emit(SearchLoading());

    try {
      final seriesResults = await _fetchResults("https://comicvine.gamespot.com/api/series_list", event.query);
      final comicsResults = await _fetchResults("https://comicvine.gamespot.com/api/issues", event.query);
      final moviesResults = await _fetchResults("https://comicvine.gamespot.com/api/movies", event.query);
      final charactersResults = await _fetchResults("https://comicvine.gamespot.com/api/characters", event.query);

      emit(SearchLoaded(
        seriesResults: seriesResults,
        comicsResults: comicsResults,
        moviesResults: moviesResults,
        charactersResults: charactersResults,
      ));
    } catch (e) {
      emit(SearchError("Erreur lors de la recherche"));
    }
  }

  Future<List<Map<String, dynamic>>> _fetchResults(String url, String query) async {
    final response = await http.get(Uri.parse("$url?api_key=$_apiKey&format=json&filter=name:$query"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['results'] as List).map((item) {
        return {
          "id": item["id"], // Ajout de l'identifiant pour la navigation vers la DetailPage
          "imageUrl": item["image"]?["medium_url"] ?? "https://via.placeholder.com/150",
          "title": item["name"] ?? "Titre inconnu",
        };
      }).toList();
    } else {
      throw Exception("Erreur API pour $url");
    }
  }
}