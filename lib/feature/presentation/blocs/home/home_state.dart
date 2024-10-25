import 'package:equatable/equatable.dart';
import 'package:spotify/feature/data/models/movie_detail/movie_info.dart';
import 'package:spotify/feature/data/models/response/movie.dart';
import '../../../data/models/category_movie.dart';

class HomeState extends Equatable {
  final int currentPageIndex;
  final bool isConnect;
  final Map<CategoryMovie, List<Movie>> movies;
  final MapEntry<String, Movie>? openMovie;


  HomeState({
    int? pageIndex,
    bool? isConnect,
    Map<CategoryMovie, List<Movie>>? movies,
    this.openMovie
  }) : currentPageIndex = pageIndex ?? 0,
      isConnect = isConnect ?? true,
      movies = movies ?? {};

  HomeState copyWith({
    int? pageIndex,
    bool? isConnect,
    Map<CategoryMovie, List<Movie>>? movies,
    MapEntry<String, Movie>? openMovie,
  }){
    return HomeState(
      pageIndex: pageIndex ?? currentPageIndex,
      isConnect: isConnect ?? this.isConnect,
      openMovie: openMovie ?? this.openMovie,
      movies: movies ?? Map.from(this.movies),
    );
  }

  HomeState copyWithPageIndex(int pageIndex,){
    return HomeState(
      pageIndex: pageIndex,
      isConnect: isConnect,
      openMovie: openMovie,
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
      openMovie: openMovie,
      movies: newMoves,
    );
  }

  @override
  List<Object?> get props => [
    currentPageIndex,
    isConnect,
    openMovie,
    movies,
  ];
}

