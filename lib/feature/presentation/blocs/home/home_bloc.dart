import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/data/models/response/movie.dart';
import '../../../data/models/category_movie.dart';
import '../../../data/repositories/movie_repo.dart';
import 'home_event.dart';
import 'home_state.dart';


class HomeBloc extends Bloc<HomeEvent, HomeState> {
  MovieRepo repo;

  HomeBloc({
    required this.repo
  } ) : super(HomeState()) {
    listenEvent();
    pageController = PageController(initialPage: state.currentPageIndex);
  }

  late PageController pageController;

  void listenEvent(){
    on<PageIndexHomeEvent>(changePageIndex);
    on<GetCategoryMovie>(getMovieCategory);
  }

  disposeHome(DisposeHomeEvent event, Emitter<HomeState> emit) async{
    emit.call(HomeState());
    pageController.jumpTo(0);
  }

  @override
  Future<void> close() {
    pageController.dispose();
    return super.close();
  }

  changePageIndex(PageIndexHomeEvent event, Emitter<HomeState> emit) async{
    emit.call(state.copyWithPageIndex(event.pageIndex));
    pageController.animateToPage(event.pageIndex, duration: const Duration(milliseconds: 200), curve: Curves.ease);
  }

  Future<void> getMovieCategory(GetCategoryMovie event, Emitter<HomeState> emit) async{
      var response = await repo.getMovieCategory(
          pageIndex: 1,
          category: event.categoryMovie
      );

      if (response.statusCode == 200) {
        List<Movie> listData = event.categoryMovie.itemDataFromJson(response.body).data ?? [];
        emit(state.copyWithMovie(
            category: event.categoryMovie,
            data: listData
        ));
      }
  }


}
