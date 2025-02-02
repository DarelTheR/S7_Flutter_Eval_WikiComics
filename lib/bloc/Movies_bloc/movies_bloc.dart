import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'movies_event.dart';
part 'movies_state.dart';

class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  final String _apiKey = "9423cc1c26178968a90ee233468fd390fd839876";

  MoviesBloc() : super(MoviesInitial()) {
    on<FetchMovies>(_onFetchMovies);
  }

  Future<void> _onFetchMovies(FetchMovies event, Emitter<MoviesState> emit) async {
    emit(MoviesLoading());
    try {
      final response = await http.get(Uri.parse(
          "https://comicvine.gamespot.com/api/movies?api_key=$_apiKey&format=json"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final movies = (data['results'] as List).map((item) {
          return {
            "id": item["id"],
            "title": item["name"] ?? "Titre inconnu",
            "releaseDate": item["release_date"] != null
                ? DateTime.tryParse(item["release_date"])?.year.toString() ??
                    "Année inconnue"
                : "Année inconnue",
            "runtime": item["runtime"] ?? "Durée inconnue",
            "imageUrl": item["image"]?["medium_url"] ??
                "https://via.placeholder.com/150",
          };
        }).toList();
        emit(MoviesLoaded(movies));
      } else {
        emit(MoviesError("Erreur lors du chargement des films"));
      }
    } catch (e) {
      emit(MoviesError(e.toString()));
    }
  }
}
