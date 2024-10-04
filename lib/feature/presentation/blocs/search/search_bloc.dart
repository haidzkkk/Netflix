import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/context_service.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/di/InjectionContainer.dart';
import 'package:spotify/feature/presentation/blocs/setting/setting_cubit.dart';
import '../../../data/models/category_movie.dart';
import '../../../data/models/response/movie.dart';
import '../../../data/models/status.dart';
import '../../../data/repositories/movie_repo.dart';
part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Cubit<SearchState> {
  MovieRepo repo;
  SearchBloc({required this.repo}) : super(SearchState());

  late TabController tabController;
  SettingCubit? settingCubit;
  List<CategoryMovie> get categories => settingCubit?.state.favouriteCategories ?? [];

  initSettingCubit(){
    settingCubit = sl<ContextService>().context?.read<SettingCubit>();
  }

  initScreen({required TabController tabController}){
    this.tabController = tabController;
  }

  disposeScreen(){
    tabController.dispose();
    emit(SearchState());
  }

  void pageTabCategorySearch(CategoryMovie category){
    var pageIndex = categories.indexWhere((element) => element.slug == category.slug);
    if(pageIndex != -1){
      pageTabIndexSearch(pageIndex);
    }
  }

  void pageTabIndexSearch(int pageIndex){
    emit.call(state.copyWithTabPageIndex(pageIndex: pageIndex));
    try{
      if(pageIndex != tabController.index){
        tabController.animateTo(pageIndex);
      }
    }catch(e){
      printData("$e");
    }
  }

  fetchMoviesCategory(CategoryMovie categoryMovie, [bool? refresh]) async{
    if(state.searchMovies[categoryMovie]?.status == StatusEnum.loading) return;

    List<Movie> listMovies = List.from(state.searchMovies[categoryMovie]?.data ?? []);
    int pageIndex = refresh == true ? 0 : (state.searchPageIndex[categoryMovie] ?? 0);

    emit(state.copyWithSearchMovie(
      categoryMovie: categoryMovie,
      searchMovie: Status.loading(data: listMovies)
    ));

    var response = await repo.getMovieCategory(
        category: categoryMovie,
        pageIndex: pageIndex + 1
    );

    if(refresh == true) listMovies.clear();

    if (response.statusCode == 200) {
      var data = categoryMovie.itemDataFromJson(response.body);
      listMovies.addAll(data.data ?? []);

      emit(
          state.copyWithSearchMovie(
              categoryMovie: categoryMovie,
              pageIndex: data.pageIndex ?? (pageIndex + 1),
              lastPage: data.isLastPage,
              searchMovie: Status.success(data: listMovies)
          )
      );
    }else{
      emit(
          state.copyWithSearchMovie(
              categoryMovie: categoryMovie,
              pageIndex: ++pageIndex,
              searchMovie: Status.failed(
                  data: listMovies,
                  message: "Get failed"
              )
          )
      );
    }

    if(pageIndex == 0 || pageIndex % 3 != 0){
      fetchMoviesCategory(categoryMovie);
    }
  }

  fetchTextSearchMovies(String strSearch, [int? limit]) async{
    var categoryMovie = CategoryMovie.search;

    emit(state.copyWithSearchMovie(
      categoryMovie: categoryMovie,
      searchMovie: Status.loading(data: state.searchMovies[categoryMovie]?.data)
    ));

    var response = await repo.searchMovie(
        keyword: strSearch,
        limit: limit
    );

    if (response.statusCode == 200) {
      var data = categoryMovie.itemDataFromJson(response.body);

      emit(
          state.copyWithSearchMovie(
              categoryMovie: categoryMovie,
              pageIndex: 1,
              lastPage: data.isLastPage,
              searchMovie: Status.success(data: data.data)
          )
      );
    }else{
      emit(
          state.copyWithSearchMovie(
              categoryMovie: categoryMovie,
              pageIndex: 1,
              searchMovie: Status.failed(
                  data: const [],
                  message: response.statusText ?? "Get failed"
              )
          )
      );
    }
  }

  clearCategory([CategoryMovie? category]){
    if(category != null){
      emit(
          state.copyWithSearchMovie(
            categoryMovie: category,
            pageIndex: 1,
            lastPage: false,
            searchMovie: Status.initial(),
          )
      );
    }else{
      emit(
        state.copyWith(
          searchPageIndex: {},
          searchLastPage: {},
          searchMovies: {},
        )
      );
    }
  }

}
