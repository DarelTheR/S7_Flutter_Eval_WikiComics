part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Map<String, dynamic>> series;
  final List<Map<String, dynamic>> comics;
  final List<Map<String, dynamic>> movies;
  final List<Map<String, dynamic>> characters;

  const HomeLoaded(this.series, this.comics, this.movies, this.characters);

  @override
  List<Object> get props => [series, comics, movies, characters];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
