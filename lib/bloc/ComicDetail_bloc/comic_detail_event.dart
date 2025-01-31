part of 'comic_detail_bloc.dart';

abstract class ComicDetailEvent extends Equatable {
  const ComicDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadComicDetail extends ComicDetailEvent {
  final Map<String, dynamic> comic;

  const LoadComicDetail(this.comic);

  @override
  List<Object> get props => [comic];
}
