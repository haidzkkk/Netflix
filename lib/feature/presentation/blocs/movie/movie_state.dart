part of 'movie_bloc.dart';

class MovieState extends Equatable{
  final Status<MovieInfo> movie;
  final MovieInfo? currentMovie;
  final Episode? currentEpisode;
  final bool isExpandWatchMovie;
  final bool? isPlay;
  final bool visibleControlsPlayer;
  final int? totalTimeEpisode;
  final int? currentTimeEpisode;
  final int? timeWatchedEpisode;
  final bool? isPlayerWindow;

  MovieState({
    Status<MovieInfo>? movie,
    this.currentMovie,
    this.currentEpisode,
    bool? isExpandWatchMovie,
    this.timeWatchedEpisode,
    this.isPlay,
    bool? visibleControlsPlayer,
    this.currentTimeEpisode,
    this.totalTimeEpisode,
    this.isPlayerWindow,
  }) : movie = movie ?? Status.initial(),
        visibleControlsPlayer = visibleControlsPlayer ?? false,
        isExpandWatchMovie = isExpandWatchMovie ?? false;

  MovieState copyWith({
    Status<MovieInfo>? movie,
    MovieInfo? currentMovie,
    Episode? episode,
    bool? isExpandWatchMovie,
    int? totalTimeEpisode,
    int? currentTimeEpisode,
    int? timeWatchedEpisode,
    bool? isPlay,
    bool? visibleControlsPlayer,
    bool? isPlayerWindow,
  }){
    return MovieState(
      movie: movie ?? this.movie,
      currentMovie: currentMovie ?? this.currentMovie,
      currentEpisode: episode ?? currentEpisode,
      isExpandWatchMovie: isExpandWatchMovie ?? this.isExpandWatchMovie,
      totalTimeEpisode: totalTimeEpisode ?? this.totalTimeEpisode,
      currentTimeEpisode: currentTimeEpisode ?? this.currentTimeEpisode,
      timeWatchedEpisode: timeWatchedEpisode ?? this.timeWatchedEpisode,
      isPlay: isPlay ?? this.isPlay,
      visibleControlsPlayer: visibleControlsPlayer ?? this.visibleControlsPlayer,
      isPlayerWindow: isPlayerWindow ?? this.isPlayerWindow,
    );
  }

  MovieState copyWithAbsolute({
    MovieInfo? movie,
    Episode? episode,
    bool? isExpandedWatchMovie,
    int? totalTimeEpisode,
    int? currentTimeEpisode,
    int? timeWatchedEpisode,
    bool? isPlayed,
  }){
    return MovieState(
      movie: this.movie,
      currentMovie: movie,
      currentEpisode: episode,
      isExpandWatchMovie: isExpandedWatchMovie ?? false,
      totalTimeEpisode: totalTimeEpisode,
      currentTimeEpisode: currentTimeEpisode,
      timeWatchedEpisode: timeWatchedEpisode,
      isPlay: isPlayed,
    );
  }

  MovieState copyWithResetStateEpisode({
    bool? isPlayed,
    int? totalTimeEpisode,
    int? currentTimeEpisode,
  }){
    return MovieState(
      movie: movie,
      currentMovie: currentMovie,
      currentEpisode: currentEpisode,
      isExpandWatchMovie: isExpandWatchMovie,
      totalTimeEpisode: totalTimeEpisode,
      currentTimeEpisode: currentTimeEpisode,
      timeWatchedEpisode: timeWatchedEpisode,
      isPlay: isPlayed,
    );
  }

  @override
  List<Object?> get props => [
    movie,
    currentMovie,
    currentEpisode,
    isExpandWatchMovie,
    isPlay,
    timeWatchedEpisode,
    totalTimeEpisode,
    currentTimeEpisode,
    visibleControlsPlayer,
    isPlayerWindow,
  ];

}
