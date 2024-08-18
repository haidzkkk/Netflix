part of 'movie_bloc.dart';

sealed class MovieEvent {}

class InitMovieEvent extends MovieEvent{
  InitMovieEvent();
}

class CleanMovieEvent extends MovieEvent{
  CleanMovieEvent();
}

class CleanWatchMovieEvent extends MovieEvent{
  CleanWatchMovieEvent();
}

class GetInfoMovieEvent extends MovieEvent{
  MovieInfo movie;
  GetInfoMovieEvent({required this.movie});
}

class ChangeEpisodeMovieEvent extends MovieEvent{
  Episode? episode;
  ChangeEpisodeMovieEvent({this.episode});
}
