
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/data/models/db_local/movie_local.dart';
import 'package:spotify/feature/data/repositories/local_db_repository.dart';
import 'package:spotify/feature/presentation/blocs/watched/watched_state.dart';

class WatchedCubit extends Cubit<WatchedState>{
  LocalDbRepository localRepo;

  WatchedCubit({
    required this.localRepo
}): super(WatchedState());

  getMovieHistory({bool? isRefresh}) async{
    if(isRefresh == true){
      emit(WatchedState());
    }

    if(state.lastPage) return;

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
  }

}