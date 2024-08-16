sealed class HomeEvent {}

class DisposeHomeEvent extends HomeEvent{

}

class PageIndexHomeEvent extends HomeEvent{
  int pageIndex;
  PageIndexHomeEvent(this.pageIndex);
}

class GetAllCategoryMovie extends HomeEvent{

}