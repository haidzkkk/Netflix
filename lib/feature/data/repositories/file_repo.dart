
import 'dart:async';
import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spotify/feature/commons/utility/file_util.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/data/models/file/file_movie_episode.dart';

class FileRepository{


  /// get local path in app
  Future<Directory> getLocalPath() async{
    return await getApplicationDocumentsDirectory();
  }

  Future<Directory?> getLocalPathDownload() async{
    Directory? directory = Directory("${(await getLocalPath()).path}/download");
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return directory;
  }

  /// create path download episode with movieName and episodeName
  Future<String?> createLocalPathToDownloadVideo({required String movieName, required String episodeName}) async{
    Directory? directory = await getLocalPathDownload();

    if(directory == null){
      return null;
    }

    Directory movieDirectory = Directory("${directory.path}/$movieName");
    if (!await movieDirectory.exists()) {
      await movieDirectory.create(recursive: true);
    }

    return "${movieDirectory.path}/$episodeName.mp4";
  }

  /// get all folder movie in folder download
  Future<List<Directory>> getFolderMovies({String? movieName}) async{
    List<Directory> directories = [];

    Directory? directory = await getLocalPathDownload();
    if(movieName != null){
      directory = Directory("${directory?.path}/$movieName");
    }

    if(directory != null){
      try{
        directories = directory.listSync()
            .whereType<Directory>().toList();
      }catch(e){
        printData("Lỗi không lấy được thư mục");
      }
    }

    return directories;
  }

  /// get all file data in folder movie
  Future<List<File>> getFileMovies({String? movieName}) async{
    List<File> files = [];

    Directory? directory = await getLocalPathDownload();
    if(movieName != null){
      directory = Directory("${directory?.path}/$movieName");
    }

    if(directory != null){
      try{
        files = directory.listSync().whereType<File>().toList();
      }catch(e){
        printData("Lỗi không lấy được thư mục");
      }
    }
    return files;
  }

  /// get all movie with episode
  Future<List<FileMovieEpisode>> getAllMovieEpisode() async{
    List<FileMovieEpisode> movieEpisode = [];

    List<Directory> movieDirectories = [];
    Directory? directory = await getLocalPathDownload();
    if(directory != null){
      try{
        movieDirectories = directory.listSync()
            .whereType<Directory>().toList();
      }catch(e){
        printData("Lỗi không lấy được thư mục");
      }
    }

    await Future.wait(movieDirectories.map((movieDirectory) async{
      List<File> episode = await getFileMovies(movieName: movieDirectory.name);
      movieEpisode.add(FileMovieEpisode(movie: movieDirectory, episode: episode));
    }));
    return movieEpisode;
  }

  /// get movie with episode
  Future<FileMovieEpisode> getMovie(String movieName) async{
    Directory? movieDirectory = await getLocalPathDownload();
    movieDirectory = Directory("${movieDirectory?.path}/$movieName");
    List<File> episode = await getFileMovies(movieName: movieDirectory.name);

    return FileMovieEpisode(movie: movieDirectory, episode: episode);
  }

  /// check file episode has error
  Future<bool> checkMp4FileValidate(String filePath) async {
    Completer<bool> completer = Completer();

    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.file,
      filePath,
    );

    BetterPlayerController betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: false,
        looping: false,
        handleLifecycle: true,
        errorBuilder: (context, errorMessage) {
          completer.complete(false);
          return const SizedBox();
        },
      ),
      betterPlayerDataSource: betterPlayerDataSource,
    );

    betterPlayerController.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
        final duration = betterPlayerController.videoPlayerController?.value.duration;
        if (duration != null && duration > Duration.zero) {
          completer.complete(true);
        } else {
          completer.complete(false);
        }
      }
    });

    try {
      await betterPlayerController.setupDataSource(betterPlayerDataSource);
    } catch (error) {
      completer.complete(false);
    }

    bool isValid = await completer.future;
    betterPlayerController.dispose();
    return isValid;
  }

  Future<bool> deleteFiles(List<FileSystemEntity> files) async{
    try{
      await Future.wait(files.map((file) async{
        if(await file.exists() && file is Directory){
          file.listSync().forEach((element){
            if(element is File){
              element.deleteSync();
            }else if(element is Directory){
              deleteFiles([element]);
            }
          });
        }
        await file.delete();
      }));
      return true;
    }catch(e){
      printData("$e");
      return false;
    }
  }
}