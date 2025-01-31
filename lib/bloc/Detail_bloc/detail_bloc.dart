import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'detail_event.dart';
part 'detail_state.dart';

class DetailBloc extends Bloc<DetailEvent, DetailState> {
  DetailBloc() : super(DetailInitial()) {
    on<LoadDetail>((event, emit) {
      emit(DetailLoaded(event.media));
    });
  }
}
