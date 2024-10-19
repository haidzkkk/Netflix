
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/animated_scroll_view.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/commons/list_animation.dart';
import 'package:spotify/feature/commons/utility/file_util.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/data/local/database_helper.dart';
import 'package:spotify/feature/data/models/db_local/episode_download.dart';
import 'package:spotify/feature/data/models/db_local/movie_local.dart';
import 'package:spotify/feature/data/models/db_local/movie_status_download.dart';
import 'package:spotify/feature/data/models/file/file_movie_episode.dart';
import 'package:spotify/feature/data/models/movie_detail/movie_info.dart';
import 'package:spotify/feature/data/models/movie_detail/movie_info_response.dart';
import 'package:spotify/feature/data/models/status.dart';
import 'package:spotify/feature/data/repositories/file_repo.dart';
import 'package:spotify/feature/data/repositories/local_db_repository.dart';
import 'package:spotify/feature/di/InjectionContainer.dart';
import 'package:spotify/feature/presentation/blocs/download/download_state.dart';
import 'package:spotify/feature/presentation/blocs/movie/movie_bloc.dart';
import 'package:spotify/feature/presentation/screen/download/widget/movie_download_item.dart';

class DownloadCubit extends Cubit<DownloadState> implements ListAnimation<MovieLocal>{
  LocalDbRepository dbRepository;
  FileRepository fileRepository;

  DownloadCubit(this.dbRepository, this.fileRepository)
      : super(DownloadState()){
    keyListAnimation = GlobalKey();
  }

  @override
  late GlobalKey<AnimatedListState> keyListAnimation;

  StreamSubscription? _eventSubscription;
  Timer? periodicTimer;
  void listenEventFromService(){
    if(_eventSubscription != null) return;
    printData("start listen download");
    Future.delayed(const Duration(milliseconds: 5000)).then((_){
      if(state.moviesDownloading.isEmpty) _stopListener();
    });

    _eventSubscription = const EventChannel(AppConstants.methodEventDownload)
        .receiveBroadcastStream().listen((jsonData) {
      if(jsonData == null) return;

      Map<String, MovieLocal> movies = Map.from(state.movies);
      List<MovieStatusDownload> moviesDownloading = List.from(jsonDecode(jsonData).map((json) {
        return MovieStatusDownload.fromJson(json);
      }));
      emit(state.copyWith(moviesDownloading: moviesDownloading));

      for (var episodeDownload in state.moviesDownloading) {
        if(episodeDownload.movieId?.isNotEmpty == true && !movies.containsKey(episodeDownload.movieId)){
          movies[episodeDownload.movieId!] = MovieLocal.fromMovieStatusDownload(episodeDownload);
        }

        MovieLocal? movie = movies[episodeDownload.movieId ?? ""];
        movie?.episodesDownload ??= {};

        var movieEpisodeDownload = EpisodeDownload.fromWhenDownload(episodeDownload);
        if(episodeDownload.slug?.isNotEmpty == true && movie?.episodesDownload?.containsKey(episodeDownload.id) == false){
          movie?.episodesDownload![episodeDownload.id!] = movieEpisodeDownload;
        }else{
          movie?.episodesDownload![episodeDownload.id!]
            ?..executeProcess = movieEpisodeDownload.executeProcess
            ..status = movieEpisodeDownload.status;
        }
      }
      emit(state.copyWith(movies: movies));

      /// when the download is completed, cancel the EventChannel, periodicTimer
      if(state.moviesDownloading.length <= 1
          && state.moviesDownloading.firstOrNull?.status?.status != StatusDownload.INITIALIZATION
          && state.moviesDownloading.firstOrNull?.status?.status != StatusDownload.LOADING
      ){
        _saveEpisodeToLocalDownload();
        _stopListener();
      }
    }, onError: (error) {
      printData("event native: $error");
      _stopListener();
    });

    periodicTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _saveEpisodeToLocalDownload();
    });
  }

  void _stopListener() {
    printData("stop listen download");
    _eventSubscription?.cancel();
    _eventSubscription = null;
    periodicTimer?.cancel();
    periodicTimer = null;
    emit(state.copyWith(moviesDownloading: []));
  }

  void _saveEpisodeToLocalDownload() {
    for(var episode in state.moviesDownloading){
      dbRepository.addEpisodeToDownload(EpisodeDownload.fromWhenDownload(episode));
    }
  }

  Future<MapEntry<bool, String>> startDownloadEpisode({
    required MovieInfo? movie,
    required Episode? episode
  }) async{

    if(movie?.slug?.isNotEmpty != true
      || episode?.slug?.isNotEmpty != true){
      return const MapEntry(false, "Không tìm tên, tập phim để lưu vào local");
    }

    var localPath = await fileRepository.createLocalPathToDownloadVideo(
        movieName: movie!.slug!,
        episodeName: episode!.slug!
    );

    if(localPath == null){
      return const MapEntry(false, "Chức năng download chỉ hỗ trợ android");
    }else if(episode.linkM3u8 == null){
      return const MapEntry(false, "Không tìm thấy đường dẫn tải phim");
    }

    var movieRequestDownload = MovieStatusDownload(
      id: EpisodeDownload.getSetupId(movieId: movie.sId ?? "", slug: episode.slug ?? ""),
      slug: episode.slug,
      name: episode.name,
      movieId: movie.sId,
      movieName: "${movie.name} - ${episode.name}",
      movieSlug: movie.slug,
      // url: "https://flipfit-cdn.akamaized.net/flip_hls/661f570aab9d840019942b80-473e0b/video_h1.m3u8",
      url: episode.linkM3u8,
      localPath: localPath,
    );

    const MethodChannel(AppConstants.methodChanelDownload)
        .invokeMethod(AppConstants.downloadStartDownload, jsonEncode(movieRequestDownload.toJson()));

    Map<String, MovieLocal> movies = Map.from(state.movies);
    int listLength = movies.length;

    if(movieRequestDownload.movieId?.isNotEmpty == true && !movies.containsKey(movieRequestDownload.movieId)){
      movies[movieRequestDownload.movieId!] = MovieLocal.fromMovieInfo(movie);

      /// insert item state to list animation widget
      insertAnimationList(keyList: keyListAnimation, fromIndex: listLength, toIndex: movies.length);
    }

    dbRepository.addMovieToDownload(movies[movieRequestDownload.movieId!]!);
    emit(state.copyWith(movies: movies));


    listenEventFromService();
    return const MapEntry(true, "");
  }

  stopDownloadEpisode({
    required MovieInfo movie,
    required Episode episode
  }) {
    const MethodChannel(AppConstants.downloadStartDownload)
        .invokeMethod(AppConstants.downloadStopDownload);
  }

  getMoviesDownload({bool? isRefresh}) async{
    if(isRefresh == true){
      emit(state.copyWith(movies: {}, moviesDownloading: []));
    }

    var jsonData = await dbRepository.getMovieDownload();
    Map<String, MovieLocal> movieDownloaded = Map.fromEntries(jsonData.map((json) {
      var item = MovieLocal.fromJson(json);
      return MapEntry(item.movieId ?? "", item);
    }));

    emit(state.copyWith(movies: movieDownloaded));

    insertAnimationList(
      keyList: keyListAnimation,
      fromIndex: 0,
      toIndex: state.movies.length,
    );
  }

  void selectDeleteEpisodeDownload(Map<EpisodeDownload, bool> episode, {bool? refresh}){
    Map<String, EpisodeDownload> episodeSelectState = refresh == true
        ? {} : Map.from(state.episodeDeleteSelect);

    for (var mapEntry in episode.entries) {
      EpisodeDownload episode = mapEntry.key;
      bool isSelect = mapEntry.value;
      isSelect
        ? episodeSelectState[episode.id ?? ""] = episode
        : episodeSelectState.remove(episode.id);
    }
    emit(state.copyWith(
        episodeDeleteSelect: episodeSelectState
    ));
  }

  Future<bool> deleteMovieDownload(MovieLocal movieHistory, [List<EpisodeDownload>? episodes]) async{
    Map<String, MovieLocal> moviesState = Map.from(state.movies);

    String? movieIdSlug  = movieHistory.slug;
    String? movieId  = movieHistory.movieId;
    if(movieId?.isNotEmpty != true || movieIdSlug?.isNotEmpty != true) return false;

    /// list episode must is movie, if list is null means remove all
    List<EpisodeDownload> episodesDeleteFilter = episodes?.where((e) => e.movieId == movieId).toList() ?? movieHistory.episodesDownload?.values.toList() ?? [];
    bool isRemoveMovie;

    /// delete episode db
    List<MapEntry<EpisodeDownload?, bool>> resultsDeleteEpisodeDb = await Future.wait(episodesDeleteFilter.map((episode) async{
      return MapEntry(episode, await dbRepository.deleteEpisodeDownload(episode.id ?? "") != -1) ;
    }));
    bool isRemoveEpisodeSuccess = false;
    if(resultsDeleteEpisodeDb.isNotEmpty){
      for (var result in resultsDeleteEpisodeDb) {
        if(result.value == false) continue;
        moviesState[result.key?.movieId]?.episodesDownload?.remove(result.key?.id);
      }
    }
    isRemoveEpisodeSuccess = resultsDeleteEpisodeDb.firstWhereOrNull((MapEntry<EpisodeDownload?, bool> e) => e.value == true) != null;
    isRemoveMovie = moviesState[movieId]?.episodesDownload?.isEmpty == true;

    /// delete episode file
    FileMovieEpisode movieFolder = await fileRepository.getMovie(movieIdSlug!);
    Map<String, File> episodeFile = movieFolder.mapEpisode;
    List<File> files = episodesDeleteFilter.map((episode) => episodeFile[episode.slug]).whereType<File>().toList();
    await fileRepository.deleteFiles(files);

    bool isRemoveMovieDbSuccess = false;
    if(isRemoveMovie){
      /// delete movie db
      isRemoveMovieDbSuccess = (await dbRepository.deleteMovieAndEpisodeDownload(movieId!)) != -1;

      /// delete movie file
      await fileRepository.deleteFiles([movieFolder.movie]);
    }

    if(isRemoveMovieDbSuccess){
      /// delete list animation
      MovieLocal? movieDelete = moviesState.values.toList().firstWhereOrNull((element) => element.movieId == movieId);
      int position = movieDelete!= null ?  moviesState.values.toList().indexOf(movieDelete) : -1;
      if(position != -1){
        removeAnimationList(keyList: keyListAnimation, removeWhere: position, data: movieDelete);
      }

      /// delete data
      moviesState.remove(movieId);
    }

    emit(state.copyWith(
        movies: moviesState
    ));

    return isRemoveMovieDbSuccess || isRemoveEpisodeSuccess;
  }

  Future<bool> checkAndSyncMovieDownloading() async{
    var responses = await dbRepository.getEpisodeDownloading();
    if(responses.isNotEmpty){
      syncMovieDownloading();
    }
    return responses.isNotEmpty;
  }

  Future<void> syncMovieDownloading() async{
    showToast("Đang đồng bộ download");
    /// delay for service download emit process the movie downloading
    listenEventFromService();
    await Future.delayed(const Duration(milliseconds: 1000));
    Map<String, MovieStatusDownload> movieDownloading = Map.fromEntries(state.moviesDownloading.map(
            (e) => MapEntry(e.id ?? "", e)));

    var jsonData = await dbRepository.getMovieDownload();
    Map<String, MovieLocal> moviesDownloaded = Map.fromEntries(jsonData.map((json) {
      var item = MovieLocal.fromJson(json);
      return MapEntry(item.slug ?? "", item); /// slug to async with folder name moive
    }));

    Map<String, FileMovieEpisode> moviesFile = Map.fromEntries((await fileRepository.getAllMovieEpisode()).map((movie){
      return MapEntry(movie.movie.name, movie);
    }));


    final receivePort = ReceivePort();
    Isolate isolate = await Isolate.spawn(
        _syncMovieDownloadingInIsolate,
        [
          receivePort.sendPort,
          moviesDownloaded,
          movieDownloading,
          moviesFile
        ]
    );

    receivePort.listen((message) async{
      if(message is MapEntry){
        var path = message.key as String?;
        var episode = message.value as EpisodeDownload;
        bool validFile = path?.isNotEmpty == true
            ? await fileRepository.checkMp4FileValidate(path!)
            : false;
        episode.status = validFile ? StatusDownload.SUCCESS : StatusDownload.ERROR;
        await dbRepository.addEpisodeToDownload(episode);

      }else if(message is bool && message == true){
        receivePort.close();
        isolate.kill();

      }
    });
  }

  /// isolate always is static function or topLevel function
  static Future<void> _syncMovieDownloadingInIsolate(List<dynamic> args) async{
    FileRepository fileRepository = FileRepository();

    SendPort sendPort = args[0];
    Map<String, MovieLocal> moviesDownloaded = args[1];
    Map<String, MovieStatusDownload> movieDownloading = args[2];
    Map<String, FileMovieEpisode> moviesFile = args[3];


    /// sync file to db
    for (var movieDb in moviesDownloaded.values) {
      FileMovieEpisode? movieFile = moviesFile[movieDb.slug];
      if(movieFile == null){
        continue;
      }

      Map<String, File> episodesFile = movieFile.mapEpisode;
      await Future.wait(movieDb.episodesDownload?.values.map((episode) async {
        /// check movie not downloading
        if(movieDownloading[episode.id] == null){

          /// send to main isolate to handle db
          sendPort.send(MapEntry(episodesFile[episode.slug]?.path, episode));
        }
      }) ?? []);
    }

    /// sync db to file
    for(var movieFile in moviesFile.values) {
      MovieLocal? movieDownload = moviesDownloaded[movieFile.movie.name];

      /// delete folder movie
      if(movieDownload == null){
        fileRepository.deleteFiles([movieFile.movie]);
        continue;
      }

      /// delete file episode
      for (var episodeFile in movieFile.episode) {
        if(movieDownload.movieId == null) continue;
        EpisodeDownload? episodeDownload = movieDownload.episodesDownload?[EpisodeDownload.getSetupId(movieId: movieDownload.movieId!, slug: episodeFile.name)];
        if(episodeDownload == null){
          fileRepository.deleteFiles([episodeFile]);
        }
      }
    }

    sendPort.send(true);
  }

  @override
  insertAnimationList({
    required GlobalKey<AnimatedListState> keyList,
    required int fromIndex,
    required int toIndex
  }) {
    if(fromIndex == 0){
      removeAnimationList(keyList: keyList);
    }
    for (int offset = fromIndex; offset < toIndex; offset++) {
      keyList.currentState?.insertItem(offset);
    }
  }

  @override
  removeAnimationList({
    required GlobalKey<AnimatedListState> keyList,
    int? removeWhere,
    MovieLocal? data
  }) {
    if(removeWhere != null){
      keyListAnimation.currentState?.removeItem(
          removeWhere,
              (context, animation) => MovieDownloadItem(
                movieLocal: data ?? MovieLocal(),
                animation: animation,
              ),
          duration: const Duration(milliseconds: 300)
      );
    }else{
      keyListAnimation.currentState?.removeAllItems(
              (context, animation) => const SizedBox(),
          duration: const Duration(milliseconds: 300)
      );
    }
  }
}
