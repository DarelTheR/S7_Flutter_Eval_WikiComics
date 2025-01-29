// lib/bloc/series_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'series_event.dart';
part 'series_state.dart';

class SeriesBloc extends Bloc<SeriesEvent, SeriesState> {
  final String _apiKey = "91af37aec2e88b4f28ab323c9130d96787c22b2e";

  SeriesBloc() : super(SeriesInitial()) {
    on<FetchSeries>(_onFetchSeries);
  }

  Future<void> _onFetchSeries(FetchSeries event, Emitter<SeriesState> emit) async {
    emit(SeriesLoading());
    try {
      final response = await http.get(Uri.parse(
          "https://api.formation-android.fr/comicvine?url=series_list&api_key=$_apiKey&format=json"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final series = (data['results'] as List).map((item) {
          return {
            "title": item["name"] ?? "Titre inconnu",
            "studio": item["publisher"]?["name"] ?? "Studio inconnu",
            "episodes": item["count_of_episodes"] ?? 0,
            "year": item["start_year"] ?? "Année inconnue",
            "imageUrl": item["image"]?["medium_url"] ?? "https://via.placeholder.com/150",
          };
        }).toList();
        emit(SeriesLoaded(series));
      } else {
        emit(SeriesError("Erreur lors du chargement des séries"));
      }
    } catch (e) {
      emit(SeriesError(e.toString()));
    }
  }
}