// lib/bloc/comics_event.dart
part of 'comics_bloc.dart';

abstract class ComicsEvent extends Equatable {
  const ComicsEvent();

  @override
  List<Object> get props => [];
}

class FetchComics extends ComicsEvent {}