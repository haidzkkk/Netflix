import 'package:equatable/equatable.dart';
import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/data/models/response/movie.dart';

enum CategoryMovie{
  movieNew(slug: "phim-moi-cap-nhat", path: AppConstants.GET_LIST_MOVIE),
  listMovieSingle(slug: "phim-le", path: AppConstants.GET_CATEGORY_1),
  listCartoon(slug: "hoat-hinh", path: AppConstants.GET_CATEGORY_1),
  listTvShow(slug: "tv-shows", path: AppConstants.GET_CATEGORY_1),
  listMovieAction(slug: "hanh-dong", path: AppConstants.GET_CATEGORY_2),
  listEmotional(slug: "tinh-cam", path: AppConstants.GET_CATEGORY_2),
  ;

  final String slug;
  final String path;
  const CategoryMovie({required this.slug, required this.path});
}

class HomeState extends Equatable {
  final int currentPageIndex;
  final Map<CategoryMovie, List<Movie>> movies;

  HomeState({
    int? pageIndex,
    Map<CategoryMovie, List<Movie>>? movies
  }) : currentPageIndex = pageIndex ?? 0,
      movies = movies ?? {};

  HomeState copyWith({
    int? pageIndex,
    Map<CategoryMovie, List<Movie>>? movies
  }){
    return HomeState(
        pageIndex: pageIndex ?? currentPageIndex,
        movies: movies ?? Map.from(this.movies)
    );
  }

  HomeState copyWithPageIndex(int pageIndex,){
    return HomeState(pageIndex: pageIndex, movies: movies);
  }

  HomeState copyWithMovie({
    required CategoryMovie category,
    required List<Movie> data
  }){
    Map<CategoryMovie, List<Movie>> newMoves = Map.from(movies);
    newMoves[category] = data;

    return HomeState(
      pageIndex: currentPageIndex,
      movies: newMoves
    );
  }


  @override
  List<Object?> get props => [currentPageIndex, movies];
}

