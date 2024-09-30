import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/data/models/db_local/episode_download.dart';
import 'package:spotify/feature/data/models/db_local/episode_local.dart';
import 'package:spotify/feature/data/models/db_local/movie_local.dart';
import 'package:spotify/feature/data/models/db_local/movie_status_download.dart';

import '../local/database_helper.dart';

class LocalDbRepository{
  DataBaseHelper dataBaseHelper;

  LocalDbRepository(this.dataBaseHelper);

  /// History

  Future<int> addMovieToHistory(MovieLocal movie) async{
    return await dataBaseHelper.insert(
        tableName: MovieLocalField.movieTableName,
        body: movie.toJson()
    );
  }

  Future<List<Map<String, dynamic>>> getAllMovieHistory({
    required int pageIndex,
    int? pageSize,
}) async{
    return await dataBaseHelper.getAll(
      tableName: MovieLocalField.movieTableName,
      arrange: const MapEntry(true, "lastTime"),
      pageSize: AppConstants.defaultPageSize,
      pageIndex: pageIndex
    );
  }

  Future<int> deleteMovieHistory(int id,) async{
    return await dataBaseHelper.delete(
      tableName: MovieLocalField.movieTableName,
      params: {
        MovieLocalField.id : id
      }
    );
  }

  Future<int> addEpisodeToHistory(EpisodeLocal episode) async{
    return await dataBaseHelper.insert(
        tableName: EpisodeLocalField.tableName,
        body: episode.toJson()
    );
  }

  Future<List<Map<String, dynamic>>> getAllEpisodeFromMovieHistory(String movieId) async{
    return await dataBaseHelper.getAll(
      tableName: EpisodeLocalField.tableName,
      whereParams: [MapEntry(EpisodeLocalField.movieId, movieId)]
    );
  }

  /// Download

  Future<int> addMovieToDownload(MovieLocal movie) async{
    return await dataBaseHelper.insert(
        tableName: MovieLocalField.movieDownloadTableName,
        body: movie.toJsonDownload()
    );
  }

  Future<int> addEpisodeToDownload(EpisodeDownload episode) async{
    return await dataBaseHelper.insert(
        tableName: EpisodeDownloadField.tableName,
        body: episode.toJson()
    );
  }

  Future<int> deleteMovieAndEpisodeDownload(String movieId,) async{
    await dataBaseHelper.delete(
        tableName: EpisodeDownloadField.tableName,
        params: {
          EpisodeDownloadField.movieId : movieId
        }
    );
    return await dataBaseHelper.delete(
        tableName: MovieLocalField.movieDownloadTableName,
        params: {
          MovieLocalField.movieId : movieId
        }
    );
  }

  Future<int> deleteEpisodeDownload(String id,) async{
    return await dataBaseHelper.delete(
        tableName: EpisodeDownloadField.tableName,
        params: {
          EpisodeDownloadField.id : id
        }
    );
  }


  Future<List<Map<String, dynamic>>> getAllEpisodeDownloadFromMovieDownload(String movieId) async{
    return await dataBaseHelper.getAll(
        tableName: EpisodeDownloadField.tableName,
        whereParams: [MapEntry(EpisodeLocalField.movieId, movieId)]
    );
  }

  Future<List<Map<String, dynamic>>> getMovieDownload({String? movieId}) async{
    var jsonData = await dataBaseHelper.query(
      query: '''SELECT 
        movie.${MovieLocalField.movieId} AS movieId,
        movie.${MovieLocalField.movieSlug} AS movieSlug,
        movie.${MovieLocalField.movieName} AS movieName,
        movie.${MovieLocalField.moviePoster} AS moviePoster,
        movie.${MovieLocalField.movieThumb} AS movieThumb,
        movie.${MovieLocalField.movieLastTime} AS movieLastTime,
        episode.${EpisodeDownloadField.id} AS episodeId,
        episode.${EpisodeDownloadField.slug} AS episodeSlug,
        episode.${EpisodeDownloadField.name} AS episodeName,
        episode.${EpisodeDownloadField.path} AS episodePath,
        episode.${EpisodeDownloadField.status} AS episodeStatus,
        episode.${EpisodeDownloadField.totalSecondTime} AS episodeTotalSecondTime
      FROM ${MovieLocalField.movieDownloadTableName} AS movie
      LEFT JOIN ${EpisodeDownloadField.tableName} AS episode
      ON movie.${MovieLocalField.movieId} = episode.${EpisodeDownloadField.movieId}
      ${movieId != null ? 'WHERE movie.${MovieLocalField.movieId} = ?' : ""}
      ORDER BY movie.${MovieLocalField.movieLastTime} DESC
      ''',
      arguments: movieId != null ? [movieId] : null
    );
    return _formatMovieAndEpisodesDownload(jsonData);
  }

  List<Map<String, dynamic>> _formatMovieAndEpisodesDownload(List<Map<String, dynamic>> queryResult) {
    Map<String, Map<String, dynamic>> movieMap = {};

    for (var row in queryResult) {
      String movieId = row[MovieLocalField.movieId];

      if (!movieMap.containsKey(movieId)) {
        movieMap[movieId] = {
          'movieId': row['movieId'],
          'slug': row['movieSlug'],
          'name': row['movieName'],
          'poster': row['moviePoster'],
          'thumb': row['movieThumb'],
          'lastTime': row['movieLastTime'],
          'episodesDownload': []
        };
      }

      if (row['episodeId'] != null) {
        movieMap[movieId]?['episodesDownload'].add({
          'id': row['episodeId'],
          'movieId': row['movieId'],
          'slug': row['episodeSlug'],
          'name': row['episodeName'],
          'path': row['episodePath'],
          'status': row['episodeStatus'],
          'totalSecondTime': row['episodeTotalSecondTime'],
        });
      }
    }
    return movieMap.values.toList();
  }

  Future<List<Map<String, dynamic>>> getEpisodeDownloading() async{
    return await dataBaseHelper.getAll(
        tableName: EpisodeDownloadField.tableName,
        whereParams: [
          const MapEntry(EpisodeDownloadField.status, StatusDownload.LOADING),
          const MapEntry(EpisodeDownloadField.status, StatusDownload.INITIALIZATION),
        ],
        whereOperators: "or"
    );
  }

}