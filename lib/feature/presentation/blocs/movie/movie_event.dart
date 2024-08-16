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
