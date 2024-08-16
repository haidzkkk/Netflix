import 'package:equatable/equatable.dart';
import 'package:spotify/feature/data/models/response/movie.dart';
import '../../../data/models/category_movie.dart';

class HomeState extends Equatable {
  final int currentPageIndex;
  final Map<CategoryMovie, List<Movie>> movies;

  HomeState({
    int? pageIndex,
    Map<CategoryMovie, List<Movie>>? movies,
  }) : currentPageIndex = pageIndex ?? 0,
      movies = movies ?? {};

  HomeState copyWith({
    int? pageIndex,
    Map<CategoryMovie, List<Movie>>? movies,
  }){
    return HomeState(
        pageIndex: pageIndex ?? currentPageIndex,
        movies: movies ?? Map.from(this.movies),
    );
  }

  HomeState copyWithPageIndex(int pageIndex,){
    return HomeState(
      pageIndex: pageIndex,
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
      movies: newMoves,
    );
  }

  @override
  List<Object?> get props => [
    currentPageIndex,
    movies,
  ];
}

