
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/feature/commons/contants/app_constants.dart';
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

class DownloadCubit extends Cubit<DownloadState>{
  LocalDbRepository dbRepository;
  FileRepository fileRepository;

  DownloadCubit(this.dbRepository, this.fileRepository) : super(DownloadState());

  StreamSubscription? _eventSubscription;
  Timer? periodicTimer;
  void listenEventFromService(){
    if(_eventSubscription != null) return;

    _eventSubscription = const EventChannel(AppConstants.methodEventDownload)
        .receiveBroadcastStream().listen((jsonData) {
      if(jsonData == null) return;

      Map<String, MovieLocal> movies = Map.from(state.movies);
      List<MovieStatusDownload> moviesDownloading = List.from(jsonDecode(jsonData).map((json) {
        var  asdasd = MovieStatusDownload.fromJson(json);
        return asdasd;
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
      url: "https://flipfit-cdn.akamaized.net/flip_hls/661f570aab9d840019942b80-473e0b/video_h1.m3u8",
      // url: episode.linkM3u8,
      localPath: localPath,
    );

    const MethodChannel(AppConstants.methodChanelDownload)
        .invokeMethod(AppConstants.downloadStartDownload, jsonEncode(movieRequestDownload.toJson()));

    Map<String, MovieLocal> movies = Map.from(state.movies);
    if(movieRequestDownload.movieId?.isNotEmpty == true && !movies.containsKey(movieRequestDownload.movieId)){
      movies[movieRequestDownload.movieId!] = MovieLocal.fromMovieInfo(movie);
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
  }

  Future<bool> checkAndSyncMovieDownloading() async{
    var responses = await dbRepository.getEpisodeDownloading();
    if(responses.isNotEmpty){
      showToast("Đang đồng bộ download");
      syncMovieDownloading();
    }
    return responses.isNotEmpty;
  }

  Future<void> syncMovieDownloading() async{
    var jsonData = await dbRepository.getMovieDownload();
    Map<String, MovieLocal> moviesDownloaded = Map.fromEntries(jsonData.map((json) {
      var item = MovieLocal.fromJson(json);
      return MapEntry(item.slug ?? "", item); /// slug to async with folder name moive
    }));

    Map<String, FileMovieEpisode> moviesFile = Map.fromEntries((await fileRepository.getAllMovies()).map((movie){
      return MapEntry(movie.movie.name, movie);
    }));


    final receivePort = ReceivePort();
    Isolate isolate = await Isolate.spawn(
        _syncMovieDownloadingInIsolate,
        [
          receivePort.sendPort,
          moviesDownloaded,
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
    SendPort sendPort = args[0];
    Map<String, MovieLocal> moviesDownloaded = args[1];
    Map<String, FileMovieEpisode> moviesFile = args[2];

    /// sync file to db
    for (var movieDb in moviesDownloaded.values) {
      FileMovieEpisode? movieFile = moviesFile[movieDb.slug];
      if(movieFile == null){
        continue;
      }

      Map<String, File> episodesFile = movieFile.mapEpisode;
      await Future.wait(movieDb.episodesDownload?.values.map((episode) async {
        String? path = episodesFile[episode.slug]?.path;

        /// send to main isolate to handle db
        sendPort.send(MapEntry(path, episode));
      }) ?? []);
    }

    /// sync db to file
    for(var movieFile in moviesFile.values) {
      MovieLocal? movieDownload = moviesDownloaded[movieFile.movie.name];

      /// delete folder movie
      if(movieDownload == null){
        await movieFile.movie.delete();
        continue;
      }

      /// delete file episode
      for (var episodeFile in movieFile.episode) {
        if(movieDownload.movieId == null) continue;
        EpisodeDownload? episodeDownload = movieDownload.episodesDownload?[EpisodeDownload.getSetupId(movieId: movieDownload.movieId!, slug: episodeFile.name)];
        if(episodeDownload == null){
          await episodeFile.delete();
        }
      }
    }

    sendPort.send(true);
  }

  Future<List<MovieLocal>> getMovieDb() async {
    var jsonData = await dbRepository.getMovieDownload();
    return List.from(jsonData.map((json) {return MovieLocal.fromJson(json);}));
  }
}
