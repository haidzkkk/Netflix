import 'package:equatable/equatable.dart';
import 'package:spotify/feature/data/models/response/movie.dart';

class HomeState extends Equatable {
  final int count;
  final List<Movie> listData;

  HomeState({
    int? count,
    List<Movie>? listData,
  }) : count = count ?? 0,
        listData = listData ?? [];


  HomeState copyWith({
    int? counter,
    List<Movie>? listData
  }){
    return HomeState(
        count: counter ?? count,
        listData: listData ?? this.listData
    );
  }

  HomeState copyWithCounter(int counter,){
    return HomeState(count: counter, listData: listData);
  }

  HomeState copyWithList(List<Movie> listData,){
    return HomeState(count: count, listData: listData);
  }


  @override
  List<Object?> get props => [count, listData];
}

