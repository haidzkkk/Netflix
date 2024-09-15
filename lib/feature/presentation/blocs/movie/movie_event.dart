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
  ChangeEpisodeMovieEvent({this.episode});
}

class SaveEpisodeMovieWatchedToLocalEvent extends MovieEvent{
  EpisodeLocal episode;
  SaveEpisodeMovieWatchedToLocalEvent({required this.episode});
}
