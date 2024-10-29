
import 'dart:io';

import 'package:spotify/feature/data/models/file/file_movie_episode.dart';

abstract class FileRepoImpl{

  /// get local path in app
  Future<Directory> getLocalPath();

  Future<Directory?> getLocalPathDownload();

  /// create path download episode with movieName and episodeName
  Future<String?> createLocalPathToDownloadVideo({
    required String movieName,
    required String episodeName
  });

  /// get all folder movie in folder download
  Future<List<Directory>> getFolderMovies({String? movieName});

  /// get all file data in folder movie
  Future<List<File>> getFileMovies({String? movieName});

  /// get all movie with episode
  Future<List<FileMovieEpisode>> getAllMovieEpisode();

  /// get movie with episode
  Future<FileMovieEpisode> getMovie(String movieName);

  /// check file episode has error
  Future<bool> checkMp4FileValidate(String filePath);

  Future<bool> deleteFiles(List<FileSystemEntity> files);
}