part of 'detail_bloc.dart';

abstract class DetailState extends Equatable {
  const DetailState();

  @override
  List<Object> get props => [];
}

class DetailInitial extends DetailState {}

class DetailLoaded extends DetailState {
  final Map<String, dynamic> media;

  const DetailLoaded(this.media);

  @override
  List<Object> get props => [media];
}
