part of 'series_bloc.dart';

abstract class SeriesState extends Equatable {
  const SeriesState();

  @override
  List<Object> get props => [];
}

class SeriesInitial extends SeriesState {}

class SeriesLoading extends SeriesState {}

class SeriesLoaded extends SeriesState {
  final List<Map<String, dynamic>> series;

  const SeriesLoaded(this.series);

  @override
  List<Object> get props => [series];
}

class SeriesError extends SeriesState {
  final String message;

  const SeriesError(this.message);

  @override
  List<Object> get props => [message];
}