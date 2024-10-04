import 'package:equatable/equatable.dart';
import 'package:spotify/feature/data/models/response/movie.dart';
import '../../../data/models/category_movie.dart';

class HomeState extends Equatable {
  final int currentPageIndex;
  final bool isConnect;
  final Map<CategoryMovie, List<Movie>> movies;


  HomeState({
    int? pageIndex,
    bool? isConnect,
    Map<CategoryMovie, List<Movie>>? movies,
  }) : currentPageIndex = pageIndex ?? 0,
      isConnect = isConnect ?? true,
      movies = movies ?? {};

  HomeState copyWith({
    int? pageIndex,
    bool? isConnect,
    Map<CategoryMovie, List<Movie>>? movies,
  }){
    return HomeState(
      pageIndex: pageIndex ?? currentPageIndex,
      isConnect: isConnect ?? this.isConnect,
      movies: movies ?? Map.from(this.movies),
    );
  }

  HomeState copyWithPageIndex(int pageIndex,){
    return HomeState(
      pageIndex: pageIndex,
      isConnect: isConnect,
      movies: movies,
    );
  }

  HomeState copyWithMovie({
    required CategoryMovie category,
    required List<Movie> data
  }){
    Map<CategoryMovie, List<Movie>> newMoves = Map.from(movies);
    newMoves[category] = data;

    return HomeState(
      pageIndex: currentPageIndex,
      isConnect: isConnect,
      movies: newMoves,
    );
  }

  @override
  List<Object?> get props => [
    currentPageIndex,
    isConnect,
    movies,
  ];
}

