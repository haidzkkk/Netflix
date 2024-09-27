
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/commons/list_animation.dart';
import 'package:spotify/feature/data/models/db_local/movie_local.dart';
import 'package:spotify/feature/data/repositories/local_db_repository.dart';
import 'package:spotify/feature/presentation/blocs/watched/watched_state.dart';
import 'package:spotify/feature/presentation/screen/watched/widget/watched_item.dart';

class WatchedCubit extends Cubit<WatchedState> implements ListAnimation{
  LocalDbRepository localRepo;

  WatchedCubit({
    required this.localRepo
  }): super(WatchedState()){
    keyListAnimation = GlobalKey();
  }

  @override
  late GlobalKey<AnimatedListState> keyListAnimation;

  clearScreen(){
    emit(WatchedState());
    removeAnimationList(keyList: keyListAnimation);
  }

  getMovieHistory({bool? isRefresh}) async{
    if(isRefresh == true){
      emit(WatchedState());
      removeAnimationList(keyList: keyListAnimation);
    }

    if(state.lastPage) return;

    int listLength = state.histories.length;

    var pageIndex = state.pageIndex;
    var mapJson = await localRepo.getAllMovieHistory(pageIndex: pageIndex);
    List<MovieLocal> histories = List.from(mapJson.map((json) => MovieLocal.fromJson(json)));

    var lastPage = state.lastPage;
    if(histories.isNotEmpty){
      pageIndex += 1;
    }else{
      lastPage = true;
    }
    emit(state.copyWith(
      histories: List.from(state.histories)..addAll(histories),
      pageIndex: pageIndex,
      lastPage: lastPage,
    ));

    insertAnimationList(
      keyList: keyListAnimation,
      fromIndex: listLength,
      toIndex: state.histories.length,
    );
  }

  Future<bool> deleteMovieHistory(MovieLocal movieHistory) async{

    bool isSuccess = (await localRepo.deleteMovieHistory(movieHistory.id)) != -1;

    if(isSuccess){
      int position = state.histories.indexOf(movieHistory);

      emit(state.copyWith(
        histories: List.from(state.histories)..removeAt(position),
      ));
      removeAnimationList(keyList: keyListAnimation, removeWhere: position);
    }

    return isSuccess;
  }

  @override
  insertAnimationList({
    required GlobalKey<AnimatedListState> keyList,
    required int fromIndex,
    required int toIndex
  }) {
    for (int offset = fromIndex; offset < toIndex; offset++) {
      keyList.currentState?.insertItem(offset);
    }
  }

  @override
  removeAnimationList({
    required GlobalKey<AnimatedListState> keyList,
    int? removeWhere,
  }) {
    if(removeWhere != null){
      keyListAnimation.currentState?.removeItem(
        removeWhere,
        (context, animation) => WatchedItem(
          movieLocal: MovieLocal(),
          animation: animation,
        ),
        duration: const Duration(milliseconds: 500)
      );
    }else{
      keyListAnimation.currentState?.removeAllItems(
          (context, animation) => const SizedBox(),
          duration: const Duration(milliseconds: 500)
      );
    }
  }

}