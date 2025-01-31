part of 'comic_detail_bloc.dart';

abstract class ComicDetailState extends Equatable {
  const ComicDetailState();

  @override
  List<Object> get props => [];
}

class ComicDetailInitial extends ComicDetailState {}

class ComicDetailLoaded extends ComicDetailState {
  final Map<String, dynamic> comic;

  const ComicDetailLoaded(this.comic);

  @override
  List<Object> get props => [comic];
}
