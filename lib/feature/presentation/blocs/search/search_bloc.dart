
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/context_service.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/data/models/data.dart';
import 'package:spotify/feature/data/models/movie_info.dart';
import 'package:spotify/feature/data/repositories/movie_repo_factory.dart';
import 'package:spotify/feature/di/injection_container.dart';
import 'package:spotify/feature/presentation/blocs/setting/setting_cubit.dart';
import '../../../data/api/kk_request/category_movie.dart';
import '../../../data/models/status.dart';
part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Cubit<SearchState> {
  MovieRepoFactory movieRepoFactory;
  SearchBloc({required this.movieRepoFactory}) : super(SearchState());

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

    List<MovieInfo> listMovies = List.from(state.searchMovies[categoryMovie]?.data ?? []);
    int pageIndex = refresh == true ? 0 : (state.searchPageIndex[categoryMovie] ?? 0);

    emit(state.copyWithSearchMovie(
      categoryMovie: categoryMovie,
      searchMovie: Status.loading(data: listMovies)
    ));

    var data = await movieRepoFactory.getMovieRepository(categoryMovie.serverType).getMovieCategory(
        category: categoryMovie,
        pageIndex: pageIndex + 1
    );

    if(refresh == true) listMovies.clear();

    if (data.statusCode == 200) {
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

  final searchCategoryMovieDelegate = CategoryMovie.kkSearch;
  fetchTextSearchMovies(String strSearch, [int? limit]) async{
    final apisCategorySearch = CategoryMovie.valueCategoriesSearch;

    emit(state.copyWithSearchMovie(
      categoryMovie: searchCategoryMovieDelegate,
      searchMovie: Status.loading(data: state.searchMovies[searchCategoryMovieDelegate]?.data)
    ));

    List<Data<List<MovieInfo>>> dataRes = await Future.wait(apisCategorySearch.map((category) =>
        movieRepoFactory.getMovieRepository(category.serverType)
            .searchMovie(keyword: strSearch, limit: limit)
    ));

    var dataSuccess = dataRes.where((Data data) => data.statusCode == 200).toList();
    if (dataSuccess.isNotEmpty) {
      var movieSearch = _mergerMultiListData(dataSuccess);
      bool isLastPage = dataSuccess.firstWhereOrNull((Data data) => data.isLastPage == true) != null;

      emit(state.copyWithSearchMovie(
          categoryMovie: searchCategoryMovieDelegate,
          pageIndex: 1,
          lastPage: isLastPage,
          searchMovie: Status.success(data: movieSearch)
      ));
    }else{
      String? msg = dataRes.firstWhereOrNull((Data data) => data.msg != null)?.msg;
      emit(
          state.copyWithSearchMovie(
              categoryMovie: searchCategoryMovieDelegate,
              pageIndex: 1,
              searchMovie: Status.failed(
                  data: const [],
                  message: msg ?? "Get failed"
              )
          )
      );
    }
  }

  List<MovieInfo> _mergerMultiListData(List<Data<List<MovieInfo>>> responseData){
    if(responseData.isEmpty) return [];
    Map<String, MovieInfo> mapData = {
      ...Map.fromEntries((responseData.first.data?.map((element) =>
          MapEntry(element.slug ?? "", element)) ?? []))
    };
    for (var i = 1; i < responseData.length; i++) {
      var data = responseData[i];
      data.data?.forEach((movie){
        if(!mapData.containsKey(movie.slug ?? "")){
          mapData[movie.slug ?? ""] = movie;
        }
      });
    }
    return mapData.values.toList();
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
