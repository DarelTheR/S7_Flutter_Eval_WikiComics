import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

part 'detail_event.dart';
part 'detail_state.dart';

class DetailBloc extends Bloc<DetailEvent, DetailState> {
  DetailBloc() : super(DetailInitial()) {
    on<LoadDetail>((event, emit) async {
      // Utilisation de l'API key et de l'identifiant (présent dans event.media['id'])
      final apiKey = "91af37aec2e88b4f28ab323c9130d96787c22b2e";
      final id = event.media['id'];
      
      // Construction de l'URL en fonction du type de média.
      // Pour cet exemple, nous ne traitons que les films.
      String endpoint = "";
      if (event.mediaType == "Movie") {
        endpoint = "https://comicvine.gamespot.com/api/movie/4025-$id/?api_key=$apiKey&format=json";
      } else if (event.mediaType == "Comic") {
        endpoint = "https://comicvine.gamespot.com/api/comic/4050-$id/?api_key=$apiKey&format=json";
      } else if (event.mediaType == "Serie") {
        // Adaptez l'URL pour les séries selon votre API
        endpoint = "https://comicvine.gamespot.com/api/serie/???-$id/?api_key=$apiKey&format=json";
      }
      
      if (endpoint.isNotEmpty) {
        try {
          final response = await http.get(Uri.parse(endpoint));
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            // Extraction de la partie "results"
            final detailedMedia = data['results'];
            emit(DetailLoaded(detailedMedia));
          } else {
            emit(DetailLoaded(event.media)); // En cas d'erreur, on renvoie les données initiales
          }
        } catch (e) {
          emit(DetailLoaded(event.media));
        }
      } else {
        emit(DetailLoaded(event.media));
      }
    });
  }
}
