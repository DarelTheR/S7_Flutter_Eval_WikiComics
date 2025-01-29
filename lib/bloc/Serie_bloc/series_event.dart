// lib/bloc/series_event.dart
part of 'series_bloc.dart';

abstract class SeriesEvent extends Equatable {
  const SeriesEvent();

  @override
  List<Object> get props => [];
}

class FetchSeries extends SeriesEvent {}