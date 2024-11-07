
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/commons/list_animation.dart';
import 'package:spotify/feature/commons/utility/file_util.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/data/models/entity/episode_download.dart';
import 'package:spotify/feature/data/models/entity/movie_local.dart';
import 'package:spotify/feature/data/models/entity/movie_status_download.dart';
import 'package:spotify/feature/data/models/episode.dart';
import 'package:spotify/feature/data/models/file/file_movie_episode.dart';
import 'package:spotify/feature/data/models/movie_info.dart';
import 'package:spotify/feature/data/repositories/file_repo.dart';
import 'package:spotify/feature/data/repositories/file_repo_impl.dart';
import 'package:spotify/feature/data/repositories/local_db_download_repo_impl.dart';
import 'package:spotify/feature/data/repositories/movie_repo_factory.dart';
import 'package:spotify/feature/blocs/download/download_state.dart';
import 'package:spotify/feature/presentation/screen/download/widget/movie_download_item.dart';

export 'download_state.dart';

class DownloadCubit extends Cubit<DownloadState> implements ListAnimation<MovieLocal>{
  MovieRepoFactory movieRepoFactory;
  LocalDbDownloadRepoImpl dbRepository;
  FileRepoImpl fileRepository;

  DownloadCubit({required this.movieRepoFactory, required this.dbRepository, required this.fileRepository})
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
        var movieLocal = MovieLocal.fromMovieStatusDownload(episodeDownload);
        var keyMovie = state.getKeyMapEntryMovies(movieLocal);

        if(episodeDownload.movieId?.isNotEmpty == true && !movies.containsKey(keyMovie)){
          movies[keyMovie] = movieLocal;
        }

        MovieLocal? movie = movies[keyMovie];
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
      printData("Không tìm tên, tập phim để lưu vào local");
      return const MapEntry(false, "Không tìm tên, tập phim để lưu vào local");
    }

    var localPath = await fileRepository.createLocalPathToDownloadVideo(
        movieName: movie!.slug!,
        episodeName: episode!.slug!
    );

    /// fetch movie to get url episode (case item download re download)
    if(episode.linkM3u8 == null){
      var movieInfo = await movieRepoFactory.getMovieRepository(movie.serverType)
          .getInfoMovie(slugMovie: movie.slug!);
      episode.linkM3u8 = movieInfo.data?.servers?.firstOrNull?.episodes?.firstWhereOrNull((Episode episode){
        return episode.slug == episode.slug!;
      })?.linkM3u8;
    }

    if(localPath == null){
      printData("Chức năng download chỉ hỗ trợ android");
      return const MapEntry(false, "Chức năng download chỉ hỗ trợ android");
    }else if(episode.linkM3u8 == null){
      printData("Không tìm thấy đường dẫn tải phim");
      return const MapEntry(false, "Không tìm thấy đường dẫn tải phim");
    }

    var movieRequestDownload = MovieStatusDownload
        .fromMovieEpisode(movie: movie, episode: episode, localPath: localPath);

    const MethodChannel(AppConstants.methodChanelDownload)
        .invokeMethod(AppConstants.downloadStartDownload, jsonEncode(movieRequestDownload.toJson()));

    Map<String, MovieLocal> movies = Map.from(state.movies);
    int listLength = movies.length;

    var movieLocal = MovieLocal.fromMovieInfo(movie);
    var movieLocalKeyMap = state.getKeyMapEntryMovies(movieLocal);
    if(movieRequestDownload.movieId?.isNotEmpty == true && !movies.containsKey(movieLocalKeyMap)){
      movies[movieLocalKeyMap] = movieLocal;

      /// insert item state to list animation widget
      insertAnimationList(keyList: keyListAnimation, fromIndex: listLength, toIndex: movies.length);
    }

    dbRepository.addMovieToDownload(movies[movieRequestDownload.movieId!]!);
    emit(state.copyWith(movies: movies));


    listenEventFromService();
    return const MapEntry(true, "");
  }

  Future<void> stopDownloadEpisode({
    required MovieInfo movie,
    required Episode episode
  }) async{
    printData("stopDownloadEpisode ${movie.name} ${episode.name}");
    var movieRequestDownload = MovieStatusDownload
        .fromMovieEpisode(movie: movie, episode: episode, localPath: "");
    await const MethodChannel(AppConstants.methodChanelDownload)
        .invokeMethod(AppConstants.downloadCancelMovieDownload, jsonEncode(movieRequestDownload.toJson()));
  }



  getMoviesDownload({bool? isRefresh}) async{
    if(isRefresh == true){
      emit(state.copyWith(movies: {}, moviesDownloading: []));
    }

    List<MovieLocal> listData = await dbRepository.getMovieDownload();
    Map<String, MovieLocal> movieDownloaded = Map.fromEntries(listData.map((item) {
      return MapEntry(state.getKeyMapEntryMovies(item), item);
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

  Future<bool> deleteMovieDownload({required MovieLocal movieDelete, List<EpisodeDownload>? episodes}) async{
    Map<String, MovieLocal> moviesState = Map.from(state.movies);

    String? movieIdSlug  = movieDelete.slug;
    String? movieId  = movieDelete.movieId;
    if(movieId?.isNotEmpty != true || movieIdSlug?.isNotEmpty != true) return false;

    /// list episode must is movie, if list is null means remove all
    List<EpisodeDownload> episodesDeleteFilter = episodes?.where((e) => e.movieId == movieId).toList() ?? movieDelete.episodesDownload?.values.toList() ?? [];
    bool isRemoveMovie;

    /// delete episode db
    List<MapEntry<EpisodeDownload?, bool>> resultsDeleteEpisodeDb = await Future.wait(episodesDeleteFilter.map((episode) async{
      return MapEntry(episode, await dbRepository.deleteEpisodeDownload(episode.id ?? "")) ;
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
      isRemoveMovieDbSuccess = await dbRepository.deleteMovieAndEpisodeDownload(movieId!);

      /// delete movie file
      await fileRepository.deleteFiles([movieFolder.movie]);
    }

    if(isRemoveMovieDbSuccess){
      /// delete list animation
      MovieLocal? movieDelete = moviesState.values.toList().firstWhereOrNull((element) => element.movieId == movieId);
      int position = movieDelete != null ?  moviesState.values.toList().indexOf(movieDelete) : -1;
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
    bool hasData = await dbRepository.checkMovieDownloading();
    if(hasData){
      syncMovieDownloading();
    }
    return hasData;
  }

  Future<void> syncMovieDownloading() async{
    showToast("Đang đồng bộ download");
    listenEventFromService();
    await Future.delayed(const Duration(milliseconds: 1000));    /// delay for service download emit the process movie downloading

    Map<String, MovieStatusDownload> movieDownloading = Map.fromEntries(state.moviesDownloading.map(
            (e) => MapEntry(e.id ?? "", e)));

    List<MovieLocal> listData = await dbRepository.getMovieDownload();
    Map<String, MovieLocal> moviesDownloaded = Map.fromEntries(listData.map((item) {
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
    FileRepoImpl fileRepository = FileRepository();

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
                movieLocal: data ?? MovieLocal(serverType: null),
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
