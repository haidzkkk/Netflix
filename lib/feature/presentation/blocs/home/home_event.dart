import '../../../data/models/category_movie.dart';

sealed class HomeEvent {}

class DisposeHomeEvent extends HomeEvent{

}

class PageIndexHomeEvent extends HomeEvent{
  int pageIndex;
  PageIndexHomeEvent(this.pageIndex);
}

class GetCategoryMovie extends HomeEvent{
  CategoryMovie categoryMovie;
  GetCategoryMovie(this.categoryMovie);
}