// lib/bloc/search_state.dart
part of 'search_bloc.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Map<String, dynamic>> seriesResults;
  final List<Map<String, dynamic>> comicsResults;
  final List<Map<String, dynamic>> moviesResults;
  final List<Map<String, dynamic>> charactersResults;

  const SearchLoaded({
    required this.seriesResults,
    required this.comicsResults,
    required this.moviesResults,
    required this.charactersResults,
  });

  @override
  List<Object> get props => [seriesResults, comicsResults, moviesResults, charactersResults];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object> get props => [message];
}