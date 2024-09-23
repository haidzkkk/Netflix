import 'package:spotify/feature/data/models/db_local/episode_download.dart';
import 'package:spotify/feature/data/models/db_local/episode_local.dart';
import 'package:spotify/feature/data/models/db_local/movie_local.dart';

import '../local/database_helper.dart';

class LocalDbRepository{
  DataBaseHelper dataBaseHelper;

  LocalDbRepository(this.dataBaseHelper);

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
      pageSize: pageSize ?? 20,
      pageIndex: pageIndex
    );
  }

  Future<int> addEpisodeToHistory(EpisodeLocal episode) async{
    return await dataBaseHelper.insert(
        tableName: EpisodeLocalField.tableName,
        body: episode.toJson()
    );
  }

  Future<List<Map<String, dynamic>>> getAllEpisodeFromMovie(String movieId) async{
    return await dataBaseHelper.getAll(
      tableName: EpisodeLocalField.tableName,
      whereParams: {EpisodeLocalField.movieId: movieId}
    );
  }

  Future<int> addEpisodeToDownload(EpisodeDownload episode) async{
    return await dataBaseHelper.insert(
        tableName: EpisodeDownloadField.tableName,
        body: episode.toJson()
    );
  }

  Future<int> addMovieToDownload(MovieLocal movie) async{
    return await dataBaseHelper.insert(
        tableName: MovieLocalField.movieDownloadTableName,
        body: movie.toJsonDownload()
    );
  }

  Future<List<Map<String, dynamic>>> getAllEpisodeDownloadFromMovie(String movieId) async{
    return await dataBaseHelper.getAll(
        tableName: EpisodeDownloadField.tableName,
        whereParams: {EpisodeLocalField.movieId: movieId}
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
    return _formatMovieAndEpisodes(jsonData);
  }

  List<Map<String, dynamic>> _formatMovieAndEpisodes(List<Map<String, dynamic>> queryResult) {
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
}