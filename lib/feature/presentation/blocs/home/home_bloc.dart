import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/data/models/response/movie.dart';

import '../../../data/models/response/collection.dart';
import '../../../data/models/response/movie_response.dart';
import '../../../data/repositories/home_repo.dart';
import 'home_event.dart';
import 'home_state.dart';


class HomeBloc extends Bloc<HomeEvent, HomeState> {
  MovieRepo repo;

  HomeBloc({
    required this.repo
  } ) : super(HomeState()) {
    listenEvent();
  }

  void listenEvent(){
    on<InitHomeEvent>((event, emit)  => emit.call(HomeState()));
    on<PageIndexHomeEvent>((event, emit) => emit.call(state.copyWithPageIndex(event.pageIndex)));
    on<GetAllCategoryMovie>(getMovie);
  }

  Future<void> getMovie(GetAllCategoryMovie event, Emitter<HomeState> emit) async{

    for (var category in CategoryMovie.values) {
      var response = await repo.getMovieCategory(
          pageIndex: 1,
          category: category
      );

      if (response.statusCode == 200) {
        List<Movie> listData = [];

        if (category.path == CategoryMovie.movieNew.path) {
          var data = MovieResponse.fromJson(response.body);
          listData = data.items ?? [];
        } else if ([
          CategoryMovie.listMovieSingle.path,
          CategoryMovie.listCartoon.path,
          CategoryMovie.listTvShow.path,
          CategoryMovie.listMovieAction.path,
          CategoryMovie.listEmotional.path
        ].contains(category.path)) {
          var data = Collection.fromJson(response.body[AppConstants.DATA]);
          listData = data.items ?? [];
        }

        emit(state.copyWithMovie(
            category: category,
            data: listData
        ));
      }
    }
  }
}
