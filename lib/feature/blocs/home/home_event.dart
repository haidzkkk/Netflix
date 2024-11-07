import 'package:spotify/feature/data/api/kk_request/category_movie.dart';
import 'package:spotify/feature/data/models/movie_info.dart';

sealed class HomeEvent {}

class DisposeHomeEvent extends HomeEvent{

}

class ChangePageIndexHomeEvent extends HomeEvent{
  int pageIndex;
  ChangePageIndexHomeEvent(this.pageIndex);
}

class OpenMovieHomeEvent extends HomeEvent{
  MovieInfo movie;
  OpenMovieHomeEvent(this.movie);
}

class GetAllCategoryMovie extends HomeEvent{
  GetAllCategoryMovie();
}

class GetCategoryMovie extends HomeEvent{
  CategoryMovie categoryMovie;
  GetCategoryMovie(this.categoryMovie);
}