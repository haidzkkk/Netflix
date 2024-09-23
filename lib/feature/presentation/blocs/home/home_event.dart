import '../../../data/models/category_movie.dart';

sealed class HomeEvent {}

class DisposeHomeEvent extends HomeEvent{

}

class ChangePageIndexHomeEvent extends HomeEvent{
  int pageIndex;
  ChangePageIndexHomeEvent(this.pageIndex);
}

class ListenNetworkConnectHomeEvent extends HomeEvent{
  bool isConnect;
  ListenNetworkConnectHomeEvent(this.isConnect);
}

class GetCategoryMovie extends HomeEvent{
  CategoryMovie categoryMovie;
  GetCategoryMovie(this.categoryMovie);
}