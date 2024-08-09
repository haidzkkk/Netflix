import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/data/models/response/movie.dart';

import '../../../data/repositories/home_repo.dart';
import 'home_event.dart';
import 'home_state.dart';


class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeRepo repo;

  HomeBloc({
    required this.repo
  } ) : super(HomeState()) {
    listenEvent();
  }

  void listenEvent(){
    on<InitHomeEvent>((event, emit) {
      emit.call(HomeState());
    });

    on<CountHomeEvent>((event, emit) {
      int count = state.count;
      count++;
      emit.call(state.copyWithCounter(count));
    });

    on<GetListHomeEvent>(getMovie);
  }

  Future<void> getMovie(GetListHomeEvent event, Emitter<HomeState> emit) async{
    var response = await repo.getListMovie(1);
    if(response.statusCode == 200){
      var data = MovieResponse.fromJson(response.body);
      emit.call(state.copyWithList(data.items ?? []));
    }else{
      emit.call(state.copyWithCounter(0));
    }
  }
}
