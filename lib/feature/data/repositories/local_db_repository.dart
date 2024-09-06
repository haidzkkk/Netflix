
import 'package:spotify/feature/commons/utility/utils.dart';
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


}