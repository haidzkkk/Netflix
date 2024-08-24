
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

  Future<List<Map<String, dynamic>>> getAllMovieHistory() async{
    return await dataBaseHelper.getAll(
      tableName: MovieLocalField.movieTableName,
      orderBy: "lastTime DESC"
    );
  }
}