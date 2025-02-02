import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'comics_event.dart';
part 'comics_state.dart';

class ComicsBloc extends Bloc<ComicsEvent, ComicsState> {
  final String _apiKey = "9423cc1c26178968a90ee233468fd390fd839876";

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
            "id": item["id"],
            "volume_title": item["volume"]?["name"] ?? "Titre inconnu",
            "issue_title": item["name"] ?? "", // Titre de l'issue (peut être vide)
            "issue_number": item["issue_number"] ?? "Inconnu",
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
