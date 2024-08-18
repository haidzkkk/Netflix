part of 'movie_bloc.dart';

class MovieState extends Equatable{
  Status<MovieInfo> movie;
  Episode? currentEpisode;

  MovieState({
    Status<MovieInfo>? movie,
    this.currentEpisode,
  }) : movie = movie ?? Status.initial();

  MovieState copyWith({
    Status<MovieInfo>? movie,
    Episode? episode,
  }){
    return MovieState(
      movie: movie ?? this.movie,
      currentEpisode: episode ?? currentEpisode,
    );
  }

  MovieState copyWithEpisode({
    Status<MovieInfo>? movie,
    Episode? episode,
  }){
    return MovieState(
      movie: movie ?? this.movie,
      currentEpisode: episode,
    );
  }

  @override
  List<Object?> get props => [movie, currentEpisode];

}
