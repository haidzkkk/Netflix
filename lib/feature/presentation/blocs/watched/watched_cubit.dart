
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/commons/list_animation.dart';
import 'package:spotify/feature/data/models/entity/movie_local.dart';
import 'package:spotify/feature/data/repositories/local_db_history_repo_impl.dart';
import 'package:spotify/feature/data/repositories/local_db_repository.dart';
import 'package:spotify/feature/presentation/blocs/watched/watched_state.dart';
import 'package:spotify/feature/presentation/screen/watched/widget/watched_item.dart';

class WatchedCubit extends Cubit<WatchedState> implements ListAnimation<MovieLocal>{
  LocalDbHistoryRepoImpl localRepo;

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
      removeAnimationList(keyList: keyListAnimation);
      emit(WatchedState());
    }

    if(state.lastPage) return;

    int listLength = state.histories.length;

    var pageIndex = state.pageIndex;
    var histories = await localRepo.getAllMovieHistory(pageIndex: pageIndex);
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

    bool isSuccess = (await localRepo.deleteMovieHistory(movieHistory.id));

    if(isSuccess){
      int position = state.histories.indexOf(movieHistory);

      emit(state.copyWith(
        histories: List.from(state.histories)..removeAt(position),
      ));
      removeAnimationList(keyList: keyListAnimation, removeWhere: position, data: movieHistory);
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
    MovieLocal? data
  }) {
    if(removeWhere != null){
      keyListAnimation.currentState?.removeItem(
        removeWhere,
        (context, animation) => WatchedItem(
          movieLocal: data ?? MovieLocal(serverType: null),
          animation: animation,
        ),
        duration: const Duration(milliseconds: 300)
      );
    }else{
      keyListAnimation.currentState?.removeAllItems(
          (context, animation) => const SizedBox(),
          duration: const Duration(milliseconds: 300)
      );
    }
  }
}