// lib/bloc/comics_state.dart
part of 'comics_bloc.dart';

abstract class ComicsState extends Equatable {
  const ComicsState();

  @override
  List<Object> get props => [];
}

class ComicsInitial extends ComicsState {}

class ComicsLoading extends ComicsState {}

class ComicsLoaded extends ComicsState {
  final List<Map<String, dynamic>> comics;

  const ComicsLoaded(this.comics);

  @override
  List<Object> get props => [comics];
}

class ComicsError extends ComicsState {
  final String message;

  const ComicsError(this.message);

  @override
  List<Object> get props => [message];
}