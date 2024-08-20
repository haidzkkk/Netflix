part of 'movie_bloc.dart';

class MovieState extends Equatable{
  Status<MovieInfo> movie;

  MovieInfo? currentMovie;
  Episode? currentEpisode;
  bool isExpandWatchMovie;

  MovieState({
    Status<MovieInfo>? movie,
    this.currentMovie,
    this.currentEpisode,
    bool? isExpandWatchMovie,
  }) : movie = movie ?? Status.initial(),
        isExpandWatchMovie = isExpandWatchMovie ?? false;

  MovieState copyWith({
    Status<MovieInfo>? movie,
    MovieInfo? currentMovie,
    Episode? episode,
    bool? isExpandWatchMovie,
  }){
    return MovieState(
      movie: movie ?? this.movie,
      currentMovie: currentMovie ?? this.currentMovie,
      currentEpisode: episode ?? currentEpisode,
      isExpandWatchMovie: isExpandWatchMovie ?? this.isExpandWatchMovie,
    );
  }

  MovieState copyWithCurrentEpisode({
    MovieInfo? movie,
    Episode? episode,
    bool? isExpandedWatchMovie,
  }){
    return MovieState(
      currentMovie: movie,
      currentEpisode: episode,
      isExpandWatchMovie: isExpandedWatchMovie ?? false,
    );
  }

  @override
  List<Object?> get props => [movie, currentMovie, currentEpisode, isExpandWatchMovie];

}
