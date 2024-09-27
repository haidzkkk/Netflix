import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/data/models/db_local/episode_download.dart';
import 'package:spotify/feature/data/models/db_local/episode_local.dart';
import 'package:spotify/feature/data/models/db_local/movie_local.dart';
import 'package:spotify/feature/data/models/db_local/movie_status_download.dart';
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

  BetterPlayerController? betterPlayerController;

  void listenEvent(){
    on<InitMovieEvent>((event, emit) => emit(MovieState()));
    on<GetInfoMovieEvent>(getMovie);
    on<CleanMovieEvent>((event, emit) => emit(state.copyWith(movie: Status.initial())));
    on<InitWatchMovieEvent>(initWatchMovie);
    on<CleanWatchMovieEvent>(cleanWatchMovieEvent);
    on<ChangeExpandedMovieEvent>(changeExpanded);
    on<ChangeEpisodeMovieEvent>(changeEpisode);
    on<UpdateDownloadEpisodeMovieEvent>(updateDownloadEpisodeMovie);
    on<ListenerBetterPlayerEvent>(onBetterPlayerEvent);
    on<UpdateShowPlayerWindowMovieEvent>(onShowPlayerWindow);

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
    MovieLocal? movieDownload = await getMovieDownload(event.movie.sId);
    var response = await repo.getInfoMovie(slugMovie: event.movie.slug ?? "",);

    if (response.statusCode == 200 || movieDownload != null) {
      MovieInfo? movieResponse = MovieInfoResponse.fromJson(response.body).movie;
      movieResponse?.episodes = movieResponse.episodes?.map((serverData){
        serverData.episode = serverData.episode?.map((episode) {
          episode.episodesDownload = movieDownload?.episodesDownload?[
            EpisodeDownload.getSetupId(movieId: event.movie.sId ?? "", slug: episode.slug ?? "")
          ];
          return episode;
        }).toList();
        return serverData;
      }).toList();
      var movie = movieResponse ?? movieDownload?.toMovieInfo();
      emit(state.copyWith(movie: Status.success(data: movie)));
    }else{
      emit(state.copyWith(movie: Status.failed(message: "Không thể lấy phim", data: event.movie)));
    }
  }

  Future<MovieLocal?> getMovieDownload(String? movieId) async{
    if(movieId?.isNotEmpty != true) return null;
    var movieDownloadJson = await dbRepository.getMovieDownload(movieId: movieId);
    if(movieDownloadJson.isEmpty) return null;
    return MovieLocal.fromJson(movieDownloadJson.first);
  }

  initWatchMovie(InitWatchMovieEvent event, Emitter<MovieState> emit) async{
    saveEpisodePreviousToLocal();

    MovieInfo currentMovie = event.movie;
    Episode? currentEpisode = currentMovie.episodes?.firstOrNull?.episode?.firstOrNull;

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
      episode: currentEpisode,
    ));
    initVideoController(
      emit: emit,
      episode: currentEpisode,
    );
    listenShowPipEventFromAndroid();
    add(ChangeExpandedMovieEvent(isExpand: true));
  }

  Future<void> cleanWatchMovieEvent(CleanWatchMovieEvent event, Emitter<MovieState> emit) async{
    saveEpisodePreviousToLocal();

    cancelListenShowPipEventFromAndroid();

    betterPlayerController?.dispose();
    betterPlayerController = null;
    emit(state.copyWithAbsolute(
      movie: null,
      episode: null,
      isExpandedWatchMovie: false,
      currentTimeEpisode: null,
      totalTimeEpisode: null,
      timeWatchedEpisode: null,
      isPlayed: null,
    ));
  }

  Future<void> changeEpisode(ChangeEpisodeMovieEvent event, Emitter<MovieState> emit) async{
    saveEpisodePreviousToLocal();
    if(event.episode == null) {
      /// fetch history episode local
    }
    emit(state.copyWith(episode: event.episode));
    initVideoController(
      episode: event.episode,
      emit: emit
    );
  }

  initVideoController({
    required Episode? episode,
    required Emitter<MovieState> emit
  }){
    print("sdasdsa đang được dispose movie initVideoController");
    betterPlayerController?.dispose();
    betterPlayerController = null;
    emit(state.copyWithResetStateEpisode(
      currentTimeEpisode: null,
      totalTimeEpisode: null,
      isPlayed: null,
    ));
    String? url = episode?.linkM3u8;
    String? localPath = episode?.episodesDownload?.path;
    late BetterPlayerDataSource dataSource;
    if(localPath != null) {
      dataSource = BetterPlayerDataSource.file(localPath);
    } else if(url != null) {
      dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network, url,
        useAsmsSubtitles: true,
      );
    } else {
      return;
    }

    betterPlayerController = BetterPlayerController(BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        fit: BoxFit.contain,
        autoPlay: true,
        eventListener: (BetterPlayerEvent event){
          add(ListenerBetterPlayerEvent(event: event));
        },
        controlsConfiguration: BetterPlayerControlsConfiguration(
            customControlsBuilder: (controller, onControlsVisibilityChanged){
              return Container(height: 100, width:  100, color: Colors.white,);
            }
        )
    ));
    betterPlayerController?.setupDataSource(dataSource);
  }

  onBetterPlayerEvent(ListenerBetterPlayerEvent event, Emitter<MovieState> emit){

    switch(event.event.betterPlayerEventType){
      case BetterPlayerEventType.progress :{
        /// get current time watch episode
        Duration? myProgress = event.event.parameters?['progress'];
        if(myProgress?.inSeconds != null){
          emit(state.copyWith(
            totalTimeEpisode: betterPlayerController?.videoPlayerController?.value.duration?.inSeconds,
            currentTimeEpisode: myProgress?.inSeconds,
          ));
        }
        break;
      }
      case BetterPlayerEventType.controlsVisible || BetterPlayerEventType.controlsHiddenStart:{
        emit(state.copyWith(
          visibleControlsPlayer: event.event.betterPlayerEventType == BetterPlayerEventType.controlsVisible,
        ));
        break;
      }
      case BetterPlayerEventType.play || BetterPlayerEventType.pause:{
        /// check when player play
        /// check time watched end show snackBar to watch continue
        if (event.event.betterPlayerEventType == BetterPlayerEventType.play) {
          int minSecond = 10;
          var currentEpisode = state.currentEpisode;
          if(currentEpisode?.episodeLocal != null
              && (currentEpisode?.episodeLocal?.currentSecond ?? 0) > minSecond
              && state.isPlay == null
          ){
            emit(state.copyWith(timeWatchedEpisode: currentEpisode?.episodeLocal?.currentSecond));
          }
          emit(state.copyWith(isPlay: true));
          listenShowPipEventFromAndroid();
        }else if(event.event.betterPlayerEventType == BetterPlayerEventType.pause && state.isPlay != null){
          emit(state.copyWith(isPlay: false));
          cancelListenShowPipEventFromAndroid();
        }
        break;
      }
      default:{
      }
    }
  }

  saveEpisodePreviousToLocal(){
    if(state.currentEpisode == null) return;
    var episodeLocal = EpisodeLocal.fromWhenWatched(
        movieID: state.currentMovie?.sId ?? "",
        body: state.currentEpisode!,
        lastTime: DateTime.now().millisecondsSinceEpoch,
        currentSecond: state.currentTimeEpisode
    );
    state.currentEpisode!.episodeLocal = episodeLocal;
    dbRepository.addEpisodeToHistory(episodeLocal);
  }

  updateDownloadEpisodeMovie(UpdateDownloadEpisodeMovieEvent event, Emitter<MovieState> emit) {
    if(event.episodesDownload.firstWhereOrNull(
            (MovieStatusDownload e) => (e.executeProcess ?? 0) == 100) == null
    ){
      return;
    }

    List<ServerData> serversData = List.from(state.currentMovie?.episodes ?? []);
    Map<String, EpisodeDownload> mapEpisodesDownload = Map.fromEntries(event.episodesDownload.map((episodeDownloading){
      return MapEntry(episodeDownloading.id ?? "", EpisodeDownload.fromWhenDownload(episodeDownloading));
    }));
    for (var serverData in serversData) {
      serverData.episode?.forEach((episode){
        String episodeDownloadId = EpisodeDownload.getSetupId(movieId: state.currentMovie?.sId ?? "", slug: episode.slug ?? "");
        EpisodeDownload? episodeDownloading = mapEpisodesDownload[episodeDownloadId];
        if(episodeDownloading != null){
          episode.episodesDownload = episodeDownloading;
        }
      });
    }

    emit(state.copyWith(
      currentMovie: state.currentMovie?.copy()?..episodes = serversData
    ));
  }

  StreamSubscription? _eventPipSubscription;
  void listenShowPipEventFromAndroid() {
    if (_eventPipSubscription != null) return;
    _eventPipSubscription = const EventChannel(AppConstants.methodEventPip)
        .receiveBroadcastStream().listen((data) {

      bool isShow = data == 1;
      add(UpdateShowPlayerWindowMovieEvent(isShow: isShow));
    });
  }

  void cancelListenShowPipEventFromAndroid() {
    add(UpdateShowPlayerWindowMovieEvent(isShow: false));
    _eventPipSubscription?.cancel();
    _eventPipSubscription = null;
  }

  onShowPlayerWindow(UpdateShowPlayerWindowMovieEvent event, Emitter<MovieState> emit) {
    emit(state.copyWith(
        isPlayerWindow: event.isShow
    ));
  }
}
