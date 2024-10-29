import 'dart:async';
import 'dart:ffi';

import 'package:better_player/better_player.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/context_service.dart';
import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/data/api/server_type.dart';
import 'package:spotify/feature/data/models/data.dart';
import 'package:spotify/feature/data/models/entity/episode_download.dart';
import 'package:spotify/feature/data/models/entity/episode_local.dart';
import 'package:spotify/feature/data/models/entity/movie_local.dart';
import 'package:spotify/feature/data/models/entity/movie_status_download.dart';
import 'package:spotify/feature/data/models/episode.dart';
import 'package:spotify/feature/data/models/movie_info.dart';
import 'package:spotify/feature/data/models/server_data.dart';
import 'package:spotify/feature/data/models/status.dart';
import 'package:spotify/feature/data/repositories/local_db_download_repo_impl.dart';
import 'package:spotify/feature/data/repositories/local_db_history_repo_impl.dart';
import 'package:spotify/feature/data/repositories/movie_repo_factory.dart';
import 'package:spotify/feature/di/injection_container.dart';
import 'package:spotify/feature/presentation/blocs/setting/setting_cubit.dart';
import 'package:spotify/feature/presentation/screen/movie/widget/custom_control_widget.dart';
part 'movie_event.dart';
part 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  MovieRepoFactory movieRepoFactory;
  SettingCubit? settingCubit;
  LocalDbHistoryRepoImpl historyRepo;
  LocalDbDownloadRepoImpl downloadRepo;

  MovieBloc({required this.movieRepoFactory, required this.historyRepo, required this.downloadRepo}) : super(MovieState()) {
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

  initSettingCubit(){
    settingCubit = sl<ContextService>().context?.read<SettingCubit>();
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
    List<Data<MovieInfo>> dataRes = await Future.wait(ServerType.values.map((serverType) =>
        movieRepoFactory.getMovieRepository(serverType)
          .getInfoMovie(slugMovie: event.movie.slug ?? "",)
    ));

    List<Data<MovieInfo>> dataSuccess = dataRes.where((data) => data.statusCode == AppConstants.HTTP_OK && data.data != null).toList();
    if (dataSuccess.isNotEmpty || movieDownload != null) {
      MovieInfo? movieResponse = _mergeServerEpisode(dataSuccess);
      var movie = movieResponse ?? movieDownload?.toMovieInfo();
      emit(state.copyWith(movie: Status.success(data: movie)));
    }else{
      emit(state.copyWith(movie: Status.failed(message: "Không thể lấy phim", data: event.movie)));
    }
  }

  MovieInfo? _mergeServerEpisode(List<Data<MovieInfo>> dataRes){
    if(dataRes.isEmpty) return null;
    MovieInfo? movieResponse = dataRes.first.data;
    for(var i = 1; i < dataRes.length; i++){
      movieResponse?.servers ??= [];
      var servers = dataRes[i].data?.servers ?? [];
      movieResponse?.servers?.addAll(servers);
    }
    return movieResponse;
  }

  Future<MovieLocal?> getMovieDownload(String? movieId) async{
    if(movieId?.isNotEmpty != true) return null;
    List<MovieLocal> listData = await downloadRepo.getMovieDownload(movieId: movieId);
    if(listData.isEmpty) return null;
    return listData.first;
  }

  initWatchMovie(InitWatchMovieEvent event, Emitter<MovieState> emit) async{
    saveEpisodePreviousToLocal();

    MovieInfo currentMovie = event.movie;
    Episode? currentEpisode = currentMovie.servers?.firstOrNull?.episode?.firstOrNull;

    /// set movie watched to local
    historyRepo.addMovieToHistory(MovieLocal.fromMovieInfo(currentMovie));
    /// get episode watched from local
    Map<String, EpisodeLocal> episodeWatched = await historyRepo.getAllEpisodeFromMovieHistory(currentMovie.sId ?? "");
    MovieLocal? movieDownload = await getMovieDownload(event.movie.sId);

    currentMovie.servers?.forEach((server){
      server.episode?.forEach((episode){
        episode.episodeWatched = episodeWatched[episode.slug];
        episode.episodesDownload = movieDownload?.episodesDownload?[
          EpisodeDownload.getSetupId(movieId: event.movie.sId ?? "", slug: episode.slug ?? "")
        ];
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
    if(localPath != null && episode?.episodesDownload?.status == StatusDownload.SUCCESS) {
      dataSource = BetterPlayerDataSource.file(localPath);
    } else if(url != null) {
      dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        url,
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
            return CustomControlsWidget(
              controller: controller,
            );
          },
          playerTheme: BetterPlayerTheme.custom,
        )
    ));
    betterPlayerController?.setupDataSource(dataSource);
  }

  bool isNextEpisode = false;
  onBetterPlayerEvent(ListenerBetterPlayerEvent event, Emitter<MovieState> emit){
    switch(event.event.betterPlayerEventType){
      case BetterPlayerEventType.progress :{
        /// get current time watch episode
        Duration? progress = event.event.parameters?['progress'];

        int? totalProcess = betterPlayerController?.videoPlayerController?.value.duration?.inSeconds;
        int? currentProcess = progress?.inSeconds;

        if(progress?.inSeconds != null && currentProcess != null){
          emit(state.copyWith(
            totalTimeEpisode: totalProcess,
            currentTimeEpisode: currentProcess,
          ));
        }

        /// auto next episode
        bool ended = totalProcess == currentProcess;
        if(ended && isNextEpisode == false && settingCubit?.state.isAutoChangeEpisode == true){
          isNextEpisode = true;
          Future.delayed(const Duration(milliseconds: 3000), (){
            List<Episode> listEpisode = state.currentMovie?.servers?.firstOrNull?.episode ?? [];
            if(listEpisode.isEmpty) return;
            int currentEpisodePosition = listEpisode.indexWhere((element) => element.slug == state.currentEpisode?.slug,);
            if(currentEpisodePosition < 0
                || (currentEpisodePosition + 1) >= listEpisode.length) return;
            Episode nextEpisode = listEpisode[currentEpisodePosition + 1];
            add(ChangeEpisodeMovieEvent(episode: nextEpisode));
          });
        }
        break;
      }
      case BetterPlayerEventType.controlsVisible || BetterPlayerEventType.controlsHiddenEnd:{
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
          if(currentEpisode?.episodeWatched != null
              && (currentEpisode?.episodeWatched?.currentSecond ?? 0) > minSecond
              && state.isPlay == null
          ){
            emit(state.copyWith(timeWatchedEpisode: currentEpisode?.episodeWatched?.currentSecond));
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
    state.currentEpisode!.episodeWatched = episodeLocal;
    historyRepo.addEpisodeToHistory(episodeLocal);
  }

  updateDownloadEpisodeMovie(UpdateDownloadEpisodeMovieEvent event, Emitter<MovieState> emit) {
    if(event.episodesDownload.firstWhereOrNull(
            (MovieStatusDownload e) => (e.executeProcess ?? 0) == 100) == null
    ){
      return;
    }

    List<ServerData> serversData = List.from(state.currentMovie?.servers ?? []);
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
      currentMovie: state.currentMovie?.copy()?..servers = serversData
    ));
  }

  StreamSubscription? _eventPipSubscription;
  void listenShowPipEventFromAndroid() {
    if(settingCubit?.state.isWatchBackground == false && _eventPipSubscription != null){
      cancelListenShowPipEventFromAndroid();
      return;
    }else if (_eventPipSubscription != null) {
      return;
    }

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
