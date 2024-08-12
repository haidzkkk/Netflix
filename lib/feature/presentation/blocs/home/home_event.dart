
sealed class HomeEvent {}

class InitHomeEvent extends HomeEvent{

}

class PageIndexHomeEvent extends HomeEvent{
  int pageIndex;
  PageIndexHomeEvent(this.pageIndex);
}

class GetAllCategoryMovie extends HomeEvent{

}
