import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

part 'detail_event.dart';
part 'detail_state.dart';

class DetailBloc extends Bloc<DetailEvent, DetailState> {
  DetailBloc() : super(DetailInitial()) {
    on<LoadDetail>((event, emit) async {
      final apiKey = "9423cc1c26178968a90ee233468fd390fd839876";
      final id = event.media['id'];
      
      String endpoint = "";
      if (event.mediaType == "Movie") {
        endpoint = "https://comicvine.gamespot.com/api/movie/4025-$id/?api_key=$apiKey&format=json";
      } else if (event.mediaType == "Comic") {
        endpoint = "https://comicvine.gamespot.com/api/issue/4000-$id/?api_key=$apiKey&format=json";
      } else if (event.mediaType == "Serie") {
        endpoint = "https://comicvine.gamespot.com/api/series/4075-$id/?api_key=$apiKey&format=json";
      } else if (event.mediaType == "Character") {
        endpoint = "https://comicvine.gamespot.com/api/character/4005-$id/?api_key=$apiKey&format=json";
      }
      
      if (endpoint.isNotEmpty) {
        try {
          final response = await http.get(Uri.parse(endpoint));
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final detailedMedia = data['results'];
            emit(DetailLoaded(detailedMedia));
          } else {
            emit(DetailLoaded(event.media));
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
