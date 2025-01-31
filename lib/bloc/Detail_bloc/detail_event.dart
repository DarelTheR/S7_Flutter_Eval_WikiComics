part of 'detail_bloc.dart';

abstract class DetailEvent extends Equatable {
  const DetailEvent();

  @override
  List<Object> get props => [];
}

class LoadDetail extends DetailEvent {
  final Map<String, dynamic> media;

  const LoadDetail(this.media);

  @override
  List<Object> get props => [media];
}
