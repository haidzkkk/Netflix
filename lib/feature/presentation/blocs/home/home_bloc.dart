import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/context_service.dart';
import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/data/api/kk_request/category_movie.dart';
import 'package:spotify/feature/data/api/server_type.dart';
import 'package:spotify/feature/data/models/movie_info.dart';
import 'package:spotify/feature/data/repositories/movie_repo_factory.dart';
import 'package:spotify/feature/data/repositories/movie_repo_impl.dart';
import 'package:spotify/feature/di/injection_container.dart';
import 'package:spotify/feature/presentation/blocs/setting/setting_cubit.dart';
import 'home_event.dart';
import 'home_state.dart';


class HomeBloc extends Bloc<HomeEvent, HomeState> {
  MovieRepoFactory movieRepoFactory;

  HomeBloc({
    required this.movieRepoFactory
  } ) : super(HomeState()) {
    listenEvent();
    listenOpenMovie();
    pageController = PageController(initialPage: state.currentPageIndex);
  }

  late PageController pageController;

  SettingCubit? settingCubit;
  List<CategoryMovie> get categories => settingCubit?.state.favouriteCategories ?? [];

  initSettingCubit(){
    settingCubit = sl<ContextService>().context?.read<SettingCubit>();
  }

  void listenEvent(){
    on<ChangePageIndexHomeEvent>(changePageIndex);
    on<OpenMovieHomeEvent>(openMovieHomeEvent);
    on<GetAllCategoryMovie>(getAllCategoryMovie);
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

  void listenOpenMovie(){
    const MethodChannel(AppConstants.methodChannelOpenMovie).setMethodCallHandler((call) async{
      switch(call.method){
        case AppConstants.openMovieInvokeMethod: {
          MovieInfo movie = MovieInfo.fromJson(jsonDecode(call.arguments.toString()), ServerType.kkPhim);
          if(movie.slug != null) add(OpenMovieHomeEvent(movie));
        }
      }
    });
  }

  void openMovieHomeEvent(OpenMovieHomeEvent event, Emitter<HomeState> emit){
    emit(state.copyWith(openMovie: MapEntry(DateTime.now().millisecond.toString(), event.movie)));
  }

  changePageIndex(ChangePageIndexHomeEvent event, Emitter<HomeState> emit) async{
    emit.call(state.copyWithPageIndex(event.pageIndex));
    pageController.animateToPage(event.pageIndex, duration: const Duration(milliseconds: 200), curve: Curves.ease);
  }

  Future<void> getAllCategoryMovie(GetAllCategoryMovie event, Emitter<HomeState> emit) async{
    for (var category in categories) {
      add(GetCategoryMovie(category));
    }
  }

  Future<void> getMovieCategory(GetCategoryMovie event, Emitter<HomeState> emit) async{
      var data = await movieRepoFactory.getMovieRepository(event.categoryMovie.serverType).getMovieCategory(
          pageIndex: 1,
          category: event.categoryMovie
      );

      if (data.statusCode == 200) {
        List<MovieInfo> listData = data.data ?? [];
        emit(state.copyWithMovie(
            category: event.categoryMovie,
            data: listData
        ));

        if(event.categoryMovie == settingCubit?.state.favouriteCategories.firstOrNull){
          settingCubit?.sendDataToAndroidWidgetProvider(
            categoryJson: jsonEncode(event.categoryMovie.toJson()),
            movieJson: jsonEncode(listData.map((e) => e.toJson()).toList())
          );
        }
      }
  }

}
