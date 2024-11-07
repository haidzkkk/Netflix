import 'package:equatable/equatable.dart';
import 'package:spotify/feature/data/api/kk_request/category_movie.dart';
import 'package:spotify/feature/data/models/movie_info.dart';

class HomeState extends Equatable {
  final int currentPageIndex;
  final Map<CategoryMovie, List<MovieInfo>> movies;
  final MapEntry<String, MovieInfo>? openMovie;

  HomeState({
    int? pageIndex,
    Map<CategoryMovie, List<MovieInfo>>? movies,
    this.openMovie
  }) : currentPageIndex = pageIndex ?? 0,
      movies = movies ?? {};

  HomeState copyWith({
    int? pageIndex,
    Map<CategoryMovie, List<MovieInfo>>? movies,
    MapEntry<String, MovieInfo>? openMovie,
  }){
    return HomeState(
      pageIndex: pageIndex ?? currentPageIndex,
      openMovie: openMovie ?? this.openMovie,
      movies: movies ?? Map.from(this.movies),
    );
  }

  HomeState copyWithPageIndex(int pageIndex,){
    return HomeState(
      pageIndex: pageIndex,
      openMovie: openMovie,
      movies: movies,
    );
  }

  HomeState copyWithMovie({
    required CategoryMovie category,
    required List<MovieInfo> data
  }){
    Map<CategoryMovie, List<MovieInfo>> newMoves = Map.from(movies);
    newMoves[category] = data;

    return HomeState(
      pageIndex: currentPageIndex,
      openMovie: openMovie,
      movies: newMoves,
    );
  }

  @override
  List<Object?> get props => [
    currentPageIndex,
    openMovie,
    movies,
  ];
}

