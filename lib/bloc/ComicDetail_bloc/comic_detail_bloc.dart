import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'comic_detail_event.dart';
part 'comic_detail_state.dart';

class ComicDetailBloc extends Bloc<ComicDetailEvent, ComicDetailState> {
  ComicDetailBloc() : super(ComicDetailInitial()) {
    on<LoadComicDetail>((event, emit) {
      emit(ComicDetailLoaded(event.comic));
    });
  }
}
