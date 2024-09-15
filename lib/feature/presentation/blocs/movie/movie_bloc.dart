import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spotify/feature/data/models/db_local/episode_local.dart';
import 'package:spotify/feature/data/models/db_local/movie_local.dart';
import 'package:spotify/feature/data/models/movie_detail/movie_info.dart';
import 'package:spotify/feature/data/models/movie_detail/movie_info_response.dart';
import 'package:spotify/feature/data/models/status.dart';
import 'package:spotify/feature/data/repositories/local_db_repository.dart';

import '../../../data/repositories/movie_repo.dart';

part 'movie_event.dart';
part 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  MovieRepo repo;
  LocalDbRepository dbRepository;

  MovieBloc(this.repo, this.dbRepository) : super(MovieState()) {
    listenEvent();
  }

  void listenEvent(){
    on<InitMovieEvent>((event, emit) => emit(MovieState()));
    on<GetInfoMovieEvent>(getMovie);
    on<CleanMovieEvent>((event, emit) => emit(state.copyWith(movie: Status.initial())));
    on<InitWatchMovieEvent>(initWatchMovie);
    on<CleanWatchMovieEvent>(cleanWatchMovieEvent);
    on<ChangeExpandedMovieEvent>(changeExpanded);
    on<ChangeEpisodeMovieEvent>(changeEpisode);

    on<SaveEpisodeMovieWatchedToLocalEvent>(saveEpisodeMovieWatchedToLocal);
  }

  var durationScroll = const Duration(milliseconds: 300);
  bool blockScrollListen = false;

  Future<void> changeExpanded(ChangeExpandedMovieEvent event, Emitter<MovieState> emit) async{
    blockScrollListen = true;
    emit(state.copyWith(isExpandWatchMovie: event.isExpand));
    Timer(durationScroll, (){
      blockScrollListen = false;
    });
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

  initWatchMovie(InitWatchMovieEvent event, Emitter<MovieState> emit) async{
    MovieInfo currentMovie = event.movie;

    /// set movie watched to local
    dbRepository.addMovieToHistory(MovieLocal.fromMovieInfo(currentMovie));
    /// get episode watched from local
    var responses = await dbRepository.getAllEpisodeFromMovie(currentMovie.sId ?? "");
    Map<String, EpisodeLocal> episodeWatched = Map.fromEntries(responses.map((element){
      var episodeLocal = EpisodeLocal.fromJson(element);
      return MapEntry(episodeLocal.slug ?? "", episodeLocal);
    }));

    currentMovie.episodes?.forEach((server){
      server.episode?.forEach((episode){
        episode.episodeLocal = episodeWatched[episode.slug];
      });
    });

    emit(state.copyWith(
      currentMovie: currentMovie,
      episode: currentMovie.episodes?.firstOrNull?.episode?.firstOrNull,
      isExpandWatchMovie: true,
    ));
  }

  Future<void> cleanWatchMovieEvent(CleanWatchMovieEvent event, Emitter<MovieState> emit) async{
    emit(state.copyWithCurrentEpisode(movie: null, episode: null, isExpandedWatchMovie: false));
  }

  Future<void> changeEpisode(ChangeEpisodeMovieEvent event, Emitter<MovieState> emit) async{
    if(event.episode == null) {
      /// fetch history episode local
    }
    emit(state.copyWith(episode: event.episode));
  }


  saveEpisodeMovieWatchedToLocal(SaveEpisodeMovieWatchedToLocalEvent event, Emitter<MovieState> emit) async{
    int success = await dbRepository.addEpisodeToHistory(event.episode);
  }

}
