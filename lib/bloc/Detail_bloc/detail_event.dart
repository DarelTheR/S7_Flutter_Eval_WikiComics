part of 'detail_bloc.dart';

abstract class DetailEvent extends Equatable {
  const DetailEvent();
  @override
  List<Object> get props => [];
}

class LoadDetail extends DetailEvent {
  final Map<String, dynamic> media;
  final String mediaType; // "Comic", "Movie", "Serie"

  const LoadDetail(this.media, this.mediaType);

  @override
  List<Object> get props => [media, mediaType];
}
