import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spotify/feature/data/models/movie_detail/movie_info.dart';
import 'package:spotify/feature/data/models/movie_detail/movie_info_response.dart';
import 'package:spotify/feature/data/models/status.dart';

import '../../../commons/utility/utils.dart';
import '../../../data/repositories/movie_repo.dart';

part 'movie_event.dart';
part 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  MovieRepo repo;

  MovieBloc(this.repo) : super(MovieState()) {
    listenEvent();
  }

  void listenEvent(){
    on<InitMovieEvent>((event, emit) => emit.call(MovieState()));
    on<CleanMovieEvent>((event, emit) => emit.call(MovieState()));
    on<CleanWatchMovieEvent>((event, emit) => emit.call(state.copyWith(episode: null)));
    on<GetInfoMovieEvent>(getMovie);
    on<ChangeEpisodeMovieEvent>(changeEpisode);
  }

  Future<void> getMovie(GetInfoMovieEvent event, Emitter<MovieState> emit) async{
    emit(state.copyWith(movie: Status.loading(data: event.movie)));

    var response = await repo.getInfoMovie(slugMovie: event.movie.slug ?? "",);

    if (response.statusCode == 200) {
      MovieInfoResponse data = MovieInfoResponse.fromJson(response.body);
      emit(state.copyWith(movie: Status.success(data: data.movie)));
    }else{
      emit(state.copyWith(movie: Status.failed(message: "Không thể lấy phim", data: event.movie)));
    }
  }

  Future<void> changeEpisode(ChangeEpisodeMovieEvent event, Emitter<MovieState> emit) async{

    if(event.episode == null) {
      /// fetch history episode local
    }
    emit(state.copyWithEpisode(episode: event.episode));
  }

}
