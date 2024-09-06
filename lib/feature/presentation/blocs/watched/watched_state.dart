
import 'package:equatable/equatable.dart';
import 'package:spotify/feature/data/models/db_local/movie_local.dart';

class WatchedState extends Equatable{
  List<MovieLocal> histories;
  int pageIndex;
  bool lastPage;

  WatchedState({
    List<MovieLocal>? histories,
    int? pageIndex,
    bool? lastPage,
  }): histories = histories ?? [],
    pageIndex = pageIndex ?? 1,
    lastPage = lastPage ?? false;

  WatchedState copyWith({
    List<MovieLocal>? histories,
    int? pageIndex,
    bool? lastPage,
  }){
    return WatchedState(
      histories: histories ?? this.histories,
      pageIndex: pageIndex ?? this.pageIndex,
      lastPage: lastPage ?? this.lastPage,
    );
  }

  @override
  List<Object?> get props => [histories, pageIndex, lastPage];

}