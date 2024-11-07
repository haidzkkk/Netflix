part of 'search_bloc.dart';

sealed class SearchEvent {}

class PageTabIndexSearchEvent extends SearchEvent{
  int pageIndex;
  PageTabIndexSearchEvent(this.pageIndex);
}

class SearchMovieEvent extends SearchEvent{
  CategoryMovie categoryMovie;
  bool? refresh;
  SearchMovieEvent(this.categoryMovie, [this.refresh]);
}

