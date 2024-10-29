import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/data/models/entity/episode_download.dart';
import 'package:spotify/feature/data/models/entity/episode_local.dart';
import 'package:spotify/feature/data/models/entity/movie_local.dart';
import 'package:spotify/feature/data/models/entity/movie_status_download.dart';
import 'package:spotify/feature/data/repositories/local_db_download_repo_impl.dart';
import 'package:spotify/feature/data/repositories/local_db_history_repo_impl.dart';

import '../local/database_helper.dart';

class LocalDbRepository implements LocalDbHistoryRepoImpl, LocalDbDownloadRepoImpl{
  DataBaseHelper dataBaseHelper;

  LocalDbRepository({required this.dataBaseHelper});

  /// History
  @override
  Future<bool> addMovieToHistory(MovieLocal movie) async{
    return await dataBaseHelper.insert(
        tableName: MovieLocalField.movieTableName,
        body: movie.toJson()
    ) != -1;
  }

  @override
  Future<List<MovieLocal>> getAllMovieHistory({
    required int pageIndex,
    int? pageSize,
}) async{
    var jsonData = await dataBaseHelper.getAll(
        tableName: MovieLocalField.movieTableName,
        arrange: const MapEntry(true, "lastTime"),
        pageSize: AppConstants.defaultPageSize,
        pageIndex: pageIndex
    );
    List<MovieLocal> histories = List.from(jsonData.map((json) => MovieLocal.fromJson(json)));

    return histories;
  }

  @override
  Future<bool> deleteMovieHistory(int id,) async{
    return await dataBaseHelper.delete(
      tableName: MovieLocalField.movieTableName,
      params: {
        MovieLocalField.id : id
      }
    ) != -1;
  }

  @override
  Future<bool> addEpisodeToHistory(EpisodeLocal episode) async{
    return await dataBaseHelper.insert(
        tableName: EpisodeLocalField.tableName,
        body: episode.toJson()
    ) != -1;
  }

  @override
  Future<Map<String, EpisodeLocal>> getAllEpisodeFromMovieHistory(String movieId) async{
    var jsonData = await dataBaseHelper.getAll(
      tableName: EpisodeLocalField.tableName,
      whereParams: [MapEntry(EpisodeLocalField.movieId, movieId)]
    );
    return Map.fromEntries(jsonData.map((element){
      var episodeLocal = EpisodeLocal.fromJson(element);
      return MapEntry(episodeLocal.slug ?? "", episodeLocal);
    }));
  }

  /// Download

  @override
  Future<bool> addMovieToDownload(MovieLocal movie) async{
    return await dataBaseHelper.insert(
        tableName: MovieLocalField.movieDownloadTableName,
        body: movie.toJsonDownload()
    ) != -1;
  }

  @override
  Future<bool> addEpisodeToDownload(EpisodeDownload episode) async{
    return await dataBaseHelper.insert(
        tableName: EpisodeDownloadField.tableName,
        body: episode.toJson()
    ) != -1;
  }

  @override
  Future<bool> deleteMovieAndEpisodeDownload(String movieId,) async{
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
    ) != -1;
  }

  @override
  Future<bool> deleteEpisodeDownload(String id,) async{
    return await dataBaseHelper.delete(
        tableName: EpisodeDownloadField.tableName,
        params: {
          EpisodeDownloadField.id : id
        }
    ) != -1;
  }

  @override
  Future<List<MovieLocal>> getMovieDownload({String? movieId}) async{
    var mapData = _formatMovieAndEpisodesDownload( await _queryMovieAndEpisodesDownload(movieId));
    return mapData.map((json) => MovieLocal.fromJson(json)).toList();
  }

  Future<List<Map<String, dynamic>>> _queryMovieAndEpisodesDownload(String? movieId) async{
    return await dataBaseHelper.query(
        query: '''SELECT 
        movie.${MovieLocalField.movieId} AS movieId,
        movie.${MovieLocalField.movieSlug} AS movieSlug,
        movie.${MovieLocalField.movieName} AS movieName,
        movie.${MovieLocalField.moviePoster} AS moviePoster,
        movie.${MovieLocalField.movieThumb} AS movieThumb,
        movie.${MovieLocalField.movieLastTime} AS movieLastTime,
        movie.${MovieLocalField.serverType} AS serverType,
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
          'serverType': row['serverType'],
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

  @override
  Future<bool> checkMovieDownloading() async{
    return (await dataBaseHelper.getAll(
        tableName: EpisodeDownloadField.tableName,
        whereParams: [
          const MapEntry(EpisodeDownloadField.status, StatusDownload.LOADING),
          const MapEntry(EpisodeDownloadField.status, StatusDownload.INITIALIZATION),
        ],
        whereOperators: "or"
    )).isNotEmpty;
  }

}