// lib/bloc/comics_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'comics_event.dart';
part 'comics_state.dart';

class ComicsBloc extends Bloc<ComicsEvent, ComicsState> {
  final String _apiKey = "91af37aec2e88b4f28ab323c9130d96787c22b2e";

  ComicsBloc() : super(ComicsInitial()) {
    on<FetchComics>(_onFetchComics);
  }

  Future<void> _onFetchComics(FetchComics event, Emitter<ComicsState> emit) async {
    emit(ComicsLoading());
    try {
      final response = await http.get(Uri.parse(
          "https://comicvine.gamespot.com/api/issues?api_key=$_apiKey&format=json"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final comics = (data['results'] as List).map((item) {
          return {
            "id": item["id"], // indispensable pour construire l'URL dans DetailBloc
            "title": item["name"] ?? "", // pour un issue, name peut être null
            "issue_number": item["issue_number"] ?? "Inconnu",
            "studio": item["publisher"]?["name"] ?? "Studio inconnu",
            "releaseDate": item["cover_date"] ?? "Date inconnue",
            "imageUrl": item["image"]?["medium_url"] ?? "https://via.placeholder.com/150",
          };
        }).toList();
        emit(ComicsLoaded(comics));
      } else {
        emit(ComicsError("Erreur lors du chargement des comics"));
      }
    } catch (e) {
      emit(ComicsError(e.toString()));
    }
  }
}