part of 'movie_bloc.dart';

sealed class MovieEvent {}

class InitMovieEvent extends MovieEvent{
  InitMovieEvent();
}

class GetInfoMovieEvent extends MovieEvent{
  MovieInfo movie;
  GetInfoMovieEvent({required this.movie});
}

class CleanMovieEvent extends MovieEvent{
  CleanMovieEvent();
}

class InitWatchMovieEvent extends MovieEvent{
  MovieInfo movie;
  InitWatchMovieEvent({required this.movie});
}
class CleanWatchMovieEvent extends MovieEvent{
  CleanWatchMovieEvent();
}

class ChangeExpandedMovieEvent extends MovieEvent{
  bool isExpand;
  ChangeExpandedMovieEvent({required this.isExpand});
}

class ChangeEpisodeMovieEvent extends MovieEvent{
  Episode? episode;
  EpisodeDownload? episodeDownload;
  ChangeEpisodeMovieEvent({this.episode, this.episodeDownload});
}

class ListenerBetterPlayerEvent extends MovieEvent{
  BetterPlayerEvent event;
  ListenerBetterPlayerEvent({required this.event});
}

class UpdateDownloadEpisodeMovieEvent extends MovieEvent{
  List<MovieStatusDownload> episodesDownload;
  UpdateDownloadEpisodeMovieEvent({required this.episodesDownload});
}

class UpdateShowPlayerWindowMovieEvent extends MovieEvent{
  bool isShow;
  UpdateShowPlayerWindowMovieEvent({required this.isShow});
}
