part of 'search_bloc.dart';

class SearchState extends Equatable {

  final int currentPageTab;
  final Map<CategoryMovie, int> searchPageIndex;
  final Map<CategoryMovie, bool> searchLastPage;
  final Map<CategoryMovie, Status<List<MovieInfo>>> searchMovies;

  SearchState({
    int? currentPageTab,
    Map<CategoryMovie, int>? searchPageIndex,
    Map<CategoryMovie, bool>? searchLastPage,
    Map<CategoryMovie, Status<List<MovieInfo>>>? searchMovies,
  }) : currentPageTab = currentPageTab ?? 0,
       searchPageIndex = searchPageIndex ?? {},
       searchLastPage = searchLastPage ?? {},
       searchMovies = searchMovies ?? {};

  SearchState copyWith({
    int? currentPageTab,
    Map<CategoryMovie, int>? searchPageIndex,
    Map<CategoryMovie, bool>? searchLastPage,
    Map<CategoryMovie, Status<List<MovieInfo>>>? searchMovies,
  }){
    return SearchState(
      currentPageTab: currentPageTab ?? this.currentPageTab,
      searchPageIndex: searchPageIndex ?? Map.from(this.searchPageIndex),
      searchLastPage: searchLastPage ?? Map.from(this.searchLastPage),
      searchMovies: searchMovies ?? Map.from(this.searchMovies),
    );
  }

  SearchState copyWithTabPageIndex({
    required int pageIndex,
  }){
    return SearchState(
      currentPageTab: pageIndex,
      searchPageIndex: searchPageIndex,
      searchMovies: searchMovies,
    );
  }

  SearchState copyWithSearchMovie({
    required CategoryMovie categoryMovie,
    required Status<List<MovieInfo>> searchMovie,
    int? pageIndex,
    bool? lastPage,
  }){
    Map<CategoryMovie, int> searchPageIndex = Map.from(this.searchPageIndex);
    if(pageIndex != null) {
      searchPageIndex[categoryMovie] = pageIndex;
    }
    Map<CategoryMovie, bool> searchLastPage = Map.from(this.searchLastPage);
    if(lastPage != null) {
      searchLastPage[categoryMovie] = lastPage;
    }

    Map<CategoryMovie, Status<List<MovieInfo>>> movies = Map.from(searchMovies);
    movies[categoryMovie] = searchMovie;

    return SearchState(
        currentPageTab: currentPageTab,
        searchPageIndex: searchPageIndex,
        searchLastPage: searchLastPage,
        searchMovies: movies,
    );
  }


  @override
  List<Object?> get props => [currentPageTab, searchPageIndex, searchMovies];
}

