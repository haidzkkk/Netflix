part of 'movie_bloc.dart';

class MovieState extends Equatable{
  Status<MovieInfo> movie;

  MovieState({
    Status<MovieInfo>? movie
  }) : movie = movie ?? Status.initial();

  MovieState copyWith({
    Status<MovieInfo>? movie
  }){
    return MovieState(
      movie: movie ?? this.movie,
    );
  }

  MovieState copyWithMovie({
    Status<MovieInfo>? movie
  }){
    return MovieState(
        movie: movie ?? this.movie,
    );
  }

  MovieState cleanState(){
    return MovieState();
  }

  @override
  List<Object?> get props => [movie,];

}
